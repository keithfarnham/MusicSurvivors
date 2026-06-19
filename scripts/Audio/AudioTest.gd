extends Control

@onready var audio_node = $AudioController as AudioController
@onready var start_pause_button = $StartPause as TextureButton
@onready var track_options = $AudioController/DebugDisplay/DebugInfo/TrackOptions as DebugTrackOptions

# Track loop timers and get_length for seamless looping
var loop_timers = {}  # timers to prepare next loop

var pause_playback_time : float

var play_texture = preload("res://sprites/play.png")
var pause_texture = preload("res://sprites/pause.png")

var title_colors = {
	TrackData.Tracks.KICK : "black",
	TrackData.Tracks.SNARE : "aqua",
	TrackData.Tracks.CYMB : "purple",
	TrackData.Tracks.SAMPLE : "green",
	TrackData.Tracks.BASS : "fuchsia",
	TrackData.Tracks.LEAD : "red",
	TrackData.Tracks.ARP : "lime",
	TrackData.Tracks.CHORD : "yellow"
}

func _reset_level_selectors():
	for trackType in TrackData.Tracks.values():
		track_options.lvl_selectors[trackType].select(0) # index 0 is lv1
		track_options.current_levels[trackType] = TrackData.Level.lv1

func _on_song_choice_item_selected(index):
	if index >= 0 and index < SongData.Songs.size():
		_reset_level_selectors()
		start_pause_button.texture_normal = play_texture
		start_pause_button.button_pressed = false
		var selected_song = SongData.Songs.values()[index]
		audio_node.load_song(selected_song)

#region Mute Toggles
func _on_all_mute_toggled(toggled_on):
	for mute in track_options.mute_toggles.values():
		mute.button_pressed = toggled_on
	
func _on_randomize_active_tracks_pressed():
	for mute in track_options.mute_toggles.values():
		mute.button_pressed = randi() % 2
#endregion Mute Toggles

#region Track level selectors
func _on_all_lv_item_selected(index):
	for trackType in TrackData.Tracks.values():
		var newLvl : TrackData.Level = TrackData.Level.values()[index]
		Log.print("[AudioTest] Setting all track's levels to %s" % [newLvl])
		track_options.current_levels[trackType] = newLvl as TrackData.Level
		track_options.lvl_selectors[trackType].select(newLvl - 1)
	audio_node.update_all_track_levels(track_options.current_levels)

func _on_randomize_levels_pressed():
	for trackType in TrackData.Tracks.values():
		var newLvl : TrackData.Level = TrackData.Level.values()[randi_range(0, TrackData.Level.size() - 1)]
		Log.print("[AudioTest] Randomizing %s level to %s" % [TrackData.Tracks.keys()[trackType], newLvl])
		track_options.current_levels[trackType] = newLvl as TrackData.Level
		track_options.lvl_selectors[trackType].select(newLvl - 1)
	audio_node.update_all_track_levels(track_options.current_levels)
	start_pause_button.texture_normal = pause_texture
#endregion Track level selectors

func _on_start_pause_pressed():
	if audio_node.playing:
		audio_node.pause()
		start_pause_button.texture_normal = play_texture
	else:
		audio_node.resume()
		start_pause_button.texture_normal = pause_texture

func _on_start_pause_mouse_entered():
	start_pause_button.modulate = Color(0.671, 0.78, 0.871)

func _on_start_pause_mouse_exited():
	start_pause_button.modulate = Color(1.0, 1.0, 1.0)

func _handle_fancy_title_colors(trackType : TrackData.Tracks, enable : bool):
	# doing parsing for fun
	var finalString = ""
	var originalText = $BigText.text as String
	var colorStartIndex= 0
	var colorEndIndex = 0
	for i in trackType + 1:
		colorStartIndex = originalText.find("=", colorEndIndex) + 1
		colorEndIndex = originalText.find("]", colorStartIndex)
	#Log.print(originalText.insert(colorStartIndex, "|\\").insert(colorEndIndex + 2, "/|")) # colorEndIndex + 2 to account for the |\ characters being added
	var to_replace_length = colorEndIndex - colorStartIndex
	finalString = originalText.erase(colorStartIndex, to_replace_length)
	finalString = finalString.insert(colorStartIndex, title_colors[trackType] if enable else "white")#originalText.left(colorEndIndex) + title_colors[trackType] if enable else "white" + originalText.right(-(colorEndIndex + to_replace_length))
	#Log.print("%s final text is %s" % [TrackData.Tracks.keys()[trackType], finalString])
	$BigText.text = finalString

func _trigger_display(trackType):
	_handle_fancy_title_colors(trackType, true)
	if trackType in track_options.display_map.keys() and track_options.display_map[trackType]:
		# show display and start timer
		track_options.display_map[trackType].visible = true
		track_options.display_timers[trackType] = Time.get_ticks_msec()
		#Log.print("[AudioTest] Display Handler - mapped %s, current level %s" % [str(TrackData.Tracks.keys()[trackType]), str(TrackData.Level.keys()[level - 1])])
	
func _display_handler():
	# hide displays after short duration
	for track in track_options.display_map.keys():
		var t = track_options.display_timers.get(track, 0)
		if t > 0 and Time.get_ticks_msec() - t > 120: # ms to show
			if track_options.display_map[track]:
				track_options.display_map[track].visible = false
				_handle_fancy_title_colors(track, false)
			track_options.display_timers[track] = 0

func _on_track_toggled(isPaused):
	start_pause_button.texture_normal = play_texture if isPaused else pause_texture

func _ready():
	# this is needed similar to how game_controller is middleman and grabs the player's active weapons to set the active audio tracks
	for track in TrackData.Tracks.values():
		var muted = false
		if track_options.mute_toggles[track].button_pressed:
			muted = true
		audio_node.set_track_active(track, muted)
	
	# setup song choice drop down
	for i in $SongChoiceControl/SongChoice.item_count:
		$SongChoiceControl/SongChoice.remove_item(i)
	for song in SongData.Songs.values():
		$SongChoiceControl/SongChoice.add_item(SongData.get_song_display_string(song)) # may want to specify id here
	
	# Load initial song
	audio_node.load_song(SongData.Songs.AnotherAudioAdventure)
	
	# connect midi event signal
	audio_node.midi_event.connect(_trigger_display)
	
	# setup random 4 active tracks
	var alreadyActive = []
	while alreadyActive.size() < 4:
		var randTrack = randi() % TrackData.Tracks.size()
		if not alreadyActive.has(randTrack):
			alreadyActive.append(randTrack)
			track_options.mute_toggles[randTrack].button_pressed = true
#			audio_node.set_track_active(randTrack, true)
	
	track_options.active_toggled.connect(_on_track_toggled)

func _process(delta):
	_display_handler()
