extends Control

@onready var audio_node = $AudioController as AudioController
@onready var track_mutes = $TrackMutes
@onready var start_pause_button = $StartPause as TextureButton
#@onready var sprite_material = $Background/SubViewportContainer/SubViewport/BackgroundSprite2D.material

#region Debug Event Handlers
@onready var kick_display = $TrackMutes/Kick/KickRect
@onready var snare_display = $TrackMutes/Snare/SnareRect
@onready var cymb_display = $TrackMutes/Cymb/CymbRect
@onready var sample_display = $TrackMutes/Sample/SampleRect
@onready var bass_display = $TrackMutes/Bass/BassRect
@onready var lead_display = $TrackMutes/Lead/LeadRect
@onready var arp_display = $TrackMutes/Arp/ArpRect
@onready var chord_display = $TrackMutes/Chord/ChordRect

# UI element references
@onready var kick_toggle = $TrackMutes/Kick
@onready var snare_toggle = $TrackMutes/Snare
@onready var cymb_toggle = $TrackMutes/Cymb
@onready var sample_toggle = $TrackMutes/Sample
@onready var bass_toggle = $TrackMutes/Bass
@onready var lead_toggle = $TrackMutes/Lead
@onready var arp_toggle = $TrackMutes/Arp
@onready var chord_toggle = $TrackMutes/Chord

# Level selectors
@onready var kick_lv = $TrackMutes/KickLv as OptionButton
@onready var snare_lv = $TrackMutes/SnareLv as OptionButton
@onready var cymb_lv = $TrackMutes/CymbLv as OptionButton
@onready var sample_lv = $TrackMutes/SampleLv as OptionButton
@onready var bass_lv = $TrackMutes/BassLv as OptionButton
@onready var lead_lv = $TrackMutes/LeadLv as OptionButton
@onready var arp_lv = $TrackMutes/ArpLv as OptionButton
@onready var chord_lv = $TrackMutes/ChordLv as OptionButton
#endregion

# Current song being played
var current_levels = {}  # selected level for each track
var mute_toggles = {}
var lvl_selectors = {}

# Track loop timers and get_length for seamless looping
var loop_timers = {}  # timers to prepare next loop

# Display mapping and timers
var display_map = {}
var display_timers = {}

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
		lvl_selectors[trackType].select(0) # index 0 is lv1
		current_levels[trackType] = TrackData.Level.lv1

func _on_song_choice_item_selected(index):
	if index >= 0 and index < SongData.Songs.size():
		_reset_level_selectors()
		start_pause_button.texture_normal = play_texture
		start_pause_button.button_pressed = false
		var selected_song = SongData.Songs.values()[index]
		audio_node.load_song(selected_song)

#region Mute Toggles
func _on_all_mute_toggled(toggled_on):
	for mute in mute_toggles.values():
		mute.button_pressed = toggled_on
	
func _on_kick_toggled(toggled_on):
	audio_node.set_track_active(TrackData.Tracks.KICK, toggled_on)

func _on_snare_toggled(toggled_on):
	audio_node.set_track_active(TrackData.Tracks.SNARE, toggled_on)

func _on_cymb_toggled(toggled_on):
	audio_node.set_track_active(TrackData.Tracks.CYMB, toggled_on)

func _on_sample_toggled(toggled_on):
	audio_node.set_track_active(TrackData.Tracks.SAMPLE, toggled_on)

func _on_bass_toggled(toggled_on):
	audio_node.set_track_active(TrackData.Tracks.BASS, toggled_on)

func _on_lead_toggled(toggled_on):
	audio_node.set_track_active(TrackData.Tracks.LEAD, toggled_on)

func _on_arp_toggled(toggled_on):
	audio_node.set_track_active(TrackData.Tracks.ARP, toggled_on)

func _on_chord_toggled(toggled_on):
	audio_node.set_track_active(TrackData.Tracks.CHORD, toggled_on)
	
func _on_randomize_active_tracks_pressed():
	for mute in mute_toggles.values():
		mute.button_pressed = randi() % 2
#endregion Mute Toggles

#region Track level selectors
func _on_all_lv_item_selected(index):
	for trackType in TrackData.Tracks.values():
		var newLvl : TrackData.Level = TrackData.Level.values()[index]
		Log.print("[AudioTest] Setting all track's levels to %s" % [newLvl])
		current_levels[trackType] = newLvl as TrackData.Level
		lvl_selectors[trackType].select(newLvl - 1)
	audio_node.update_all_track_levels(current_levels)

func _on_kick_lv_item_selected(index):
	current_levels[TrackData.Tracks.KICK] = index + 1 as TrackData.Level
	start_pause_button.texture_normal = pause_texture
	audio_node.update_track_level(TrackData.Tracks.KICK, current_levels[TrackData.Tracks.KICK])

func _on_snare_lv_item_selected(index):
	current_levels[TrackData.Tracks.SNARE] = index + 1 as TrackData.Level
	start_pause_button.texture_normal = pause_texture
	audio_node.update_track_level(TrackData.Tracks.SNARE, current_levels[TrackData.Tracks.SNARE])

func _on_cymb_lv_item_selected(index):
	current_levels[TrackData.Tracks.CYMB] = index + 1 as TrackData.Level
	start_pause_button.texture_normal = pause_texture
	audio_node.update_track_level(TrackData.Tracks.CYMB, current_levels[TrackData.Tracks.CYMB])

func _on_sample_lv_item_selected(index):
	current_levels[TrackData.Tracks.SAMPLE] = index + 1 as TrackData.Level
	start_pause_button.texture_normal = pause_texture
	audio_node.update_track_level(TrackData.Tracks.SAMPLE, current_levels[TrackData.Tracks.SAMPLE])

func _on_bass_lv_item_selected(index):
	current_levels[TrackData.Tracks.BASS] = index + 1 as TrackData.Level
	start_pause_button.texture_normal = pause_texture
	audio_node.update_track_level(TrackData.Tracks.BASS, current_levels[TrackData.Tracks.BASS])

func _on_lead_lv_item_selected(index):
	current_levels[TrackData.Tracks.LEAD] = index + 1 as TrackData.Level
	start_pause_button.texture_normal = pause_texture
	audio_node.update_track_level(TrackData.Tracks.LEAD, current_levels[TrackData.Tracks.LEAD])

func _on_arp_lv_item_selected(index):
	current_levels[TrackData.Tracks.ARP] = index + 1 as TrackData.Level
	start_pause_button.texture_normal = pause_texture
	audio_node.update_track_level(TrackData.Tracks.ARP, current_levels[TrackData.Tracks.ARP])

func _on_chord_lv_item_selected(index):
	current_levels[TrackData.Tracks.CHORD] = index + 1 as TrackData.Level
	start_pause_button.texture_normal = pause_texture
	audio_node.update_track_level(TrackData.Tracks.CHORD, current_levels[TrackData.Tracks.CHORD])

func _on_randomize_levels_pressed():
	for trackType in TrackData.Tracks.values():
		var newLvl : TrackData.Level = TrackData.Level.values()[randi_range(0, TrackData.Level.size() - 1)]
		Log.print("[AudioTest] Randomizing %s level to %s" % [TrackData.Tracks.keys()[trackType], newLvl])
		current_levels[trackType] = newLvl as TrackData.Level
		lvl_selectors[trackType].select(newLvl - 1)
	audio_node.update_all_track_levels(current_levels)
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
	if trackType in display_map.keys() and display_map[trackType]:
		# show display and start timer
		display_map[trackType].visible = true
		display_timers[trackType] = Time.get_ticks_msec()
		#Log.print("[AudioTest] Display Handler - mapped %s, current level %s" % [str(TrackData.Tracks.keys()[trackType]), str(TrackData.Level.keys()[level - 1])])
	
func _display_handler():
	# hide displays after short duration
	for track in display_map.keys():
		var t = display_timers.get(track, 0)
		if t > 0 and Time.get_ticks_msec() - t > 120: # ms to show
			if display_map[track]:
				display_map[track].visible = false
				_handle_fancy_title_colors(track, false)
			display_timers[track] = 0

func _ready():
	mute_toggles = {
		TrackData.Tracks.KICK: kick_toggle,
		TrackData.Tracks.SNARE: snare_toggle,
		TrackData.Tracks.CYMB: cymb_toggle,
		TrackData.Tracks.SAMPLE: sample_toggle,
		TrackData.Tracks.BASS: bass_toggle,
		TrackData.Tracks.LEAD: lead_toggle,
		TrackData.Tracks.ARP: arp_toggle,
		TrackData.Tracks.CHORD: chord_toggle,
	}
	
	lvl_selectors = {
		TrackData.Tracks.KICK: kick_lv,
		TrackData.Tracks.SNARE: snare_lv,
		TrackData.Tracks.CYMB: cymb_lv,
		TrackData.Tracks.SAMPLE: sample_lv,
		TrackData.Tracks.BASS: bass_lv,
		TrackData.Tracks.LEAD: lead_lv,
		TrackData.Tracks.ARP: arp_lv,
		TrackData.Tracks.CHORD: chord_lv,
	}
	
	for track in TrackData.Tracks.values():
		var muted = false
		if mute_toggles[track].button_pressed:
			muted = true
		audio_node.set_track_active(track, muted)
	
	# Initialize current levels to lv1
	for track in TrackData.Tracks.values():
		current_levels[track] = TrackData.Level.lv1
	
	# setup song choice drop down
	for i in $SongChoiceControl/SongChoice.item_count:
		$SongChoiceControl/SongChoice.remove_item(i)
	for song in SongData.Songs.values():
		$SongChoiceControl/SongChoice.add_item(SongData.get_song_display_string(song)) # may want to specify id here
	
	# Load initial song
	audio_node.load_song(SongData.Songs.testsong)
	
	# connect midi event signal
	audio_node.midi_event.connect(_trigger_display)

	# Prepare display map
	display_map = {
		TrackData.Tracks.KICK: kick_display,
		TrackData.Tracks.SNARE: snare_display,
		TrackData.Tracks.CYMB: cymb_display,
		TrackData.Tracks.SAMPLE: sample_display,
		TrackData.Tracks.BASS: bass_display,
		TrackData.Tracks.LEAD: lead_display,
		TrackData.Tracks.ARP: arp_display,
		TrackData.Tracks.CHORD: chord_display
	}
	for track in display_map.keys():
		if display_map[track]:
			display_map[track].visible = false
			display_timers[track] = 0
			
	# setup random 4 active tracks
	var alreadyActive = []
	while alreadyActive.size() < 4:
		var randTrack = randi() % TrackData.Tracks.size()
		if not alreadyActive.has(randTrack):
			alreadyActive.append(randTrack)
			mute_toggles[randTrack].button_pressed = true

func _process(delta):
	_display_handler()
