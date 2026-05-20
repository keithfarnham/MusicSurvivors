extends Control

@onready var audio_node = $AudioController as AudioController
@onready var song_choice = $SongChoice
@onready var track_mutes = $TrackMutes
@onready var sprite_material = $Background/SubViewport/BackgroundSprite2D.material

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
@onready var kick_lv = $TrackMutes/KickLv
@onready var snare_lv = $TrackMutes/SnareLv
@onready var cymb_lv = $TrackMutes/CymbLv
@onready var sample_lv = $TrackMutes/SampleLv
@onready var bass_lv = $TrackMutes/BassLv
@onready var lead_lv = $TrackMutes/LeadLv
@onready var arp_lv = $TrackMutes/ArpLv
@onready var chord_lv = $TrackMutes/ChordLv
#endregion

# Current song being played
var current_levels = {}  # selected level for each track
#var track_muted = {} # is track muted
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
	
	# Load initial song
	audio_node.load_song(SongData.Songs.testsong)

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

func _on_song_choice_item_selected(index):
	var songs = SongData.Songs
	var song_names = ["testsong", "testsong2"]
	
	if index >= 0 and index < song_names.size():
		var selected_song = SongData.Songs[song_names[index]]
		audio_node.load_song(selected_song)

#region Mute Toggles 
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
func _on_kick_lv_item_selected(index):
	current_levels[TrackData.Tracks.KICK] = index + 1 as TrackData.Level
	audio_node.update_track_level(TrackData.Tracks.KICK, current_levels[TrackData.Tracks.KICK])

func _on_snare_lv_item_selected(index):
	current_levels[TrackData.Tracks.SNARE] = index + 1 as TrackData.Level
	audio_node.update_track_level(TrackData.Tracks.SNARE, current_levels[TrackData.Tracks.SNARE])

func _on_cymb_lv_item_selected(index):
	current_levels[TrackData.Tracks.CYMB] = index + 1 as TrackData.Level
	audio_node.update_track_level(TrackData.Tracks.CYMB, current_levels[TrackData.Tracks.CYMB])

func _on_sample_lv_item_selected(index):
	current_levels[TrackData.Tracks.SAMPLE] = index + 1 as TrackData.Level
	audio_node.update_track_level(TrackData.Tracks.SAMPLE, current_levels[TrackData.Tracks.SAMPLE])

func _on_bass_lv_item_selected(index):
	current_levels[TrackData.Tracks.BASS] = index + 1 as TrackData.Level
	audio_node.update_track_level(TrackData.Tracks.BASS, current_levels[TrackData.Tracks.BASS])

func _on_lead_lv_item_selected(index):
	current_levels[TrackData.Tracks.LEAD] = index + 1 as TrackData.Level
	audio_node.update_track_level(TrackData.Tracks.LEAD, current_levels[TrackData.Tracks.LEAD])

func _on_arp_lv_item_selected(index):
	current_levels[TrackData.Tracks.ARP] = index + 1 as TrackData.Level
	audio_node.update_track_level(TrackData.Tracks.ARP, current_levels[TrackData.Tracks.ARP])

func _on_chord_lv_item_selected(index):
	current_levels[TrackData.Tracks.CHORD] = index + 1 as TrackData.Level
	audio_node.update_track_level(TrackData.Tracks.CHORD, current_levels[TrackData.Tracks.CHORD])

#func _update_track_synced(track: TrackData.Tracks):
	#audio_node.set_track_level(track, current_levels[track])
	## Get current playpack pos
	#var sync_pos = 0.0
	#if audio_node.playing:
		##var sync_stream = audio_node.stream as AudioStreamSynchronized
		#var playback_pos = audio_node.get_playback_time_sec()
		#sync_pos = playback_pos + AudioServer.get_time_since_last_mix()
	## Resume playback at the same position
	#Log.print("[AudioTest] updating track - resuming at %ss = %s + %s" % [str(sync_pos), str(audio_node.get_playback_position()), str(AudioServer.get_time_since_last_mix())])
	#call_deferred("_resume_at", sync_pos)
#
#func _update_all_tracks_synced():
	#var sync_pos = 0.0
	## update all the tracks
	#for track in TrackData.Tracks.values():
		#audio_node.set_track_level(track, current_levels[track])
	## Get current playpack pos
	#if audio_node.playing:
		##var sync_stream = audio_node.stream as AudioStreamSynchronized
		#var playback_pos = audio_node.get_playback_position()
		#sync_pos = playback_pos + AudioServer.get_time_since_last_mix()
	#Log.print("[AudioTest] updating all tracks - resuming at %ss" % [str(sync_pos)])
	#call_deferred("_resume_at", sync_pos)
#
#func _resume_at(playback_pos: float):
	#if audio_node:
		#audio_node.play(playback_pos)

func _on_randomize_levels_pressed():
	for trackType in TrackData.Tracks.values():
		var newLvl : TrackData.Level = TrackData.Level.values()[randi_range(0, TrackData.Level.size() - 1)]
		Log.print("[AudioTest] Randomizing %s level to %s" % [TrackData.Tracks.keys()[trackType], newLvl])
		current_levels[trackType] = newLvl as TrackData.Level
		lvl_selectors[trackType].select(newLvl - 1)
	audio_node.update_all_tracks_synced(current_levels)

#endregion Track level selectors

func _on_start_pause_pressed():
	if audio_node.playing:
		audio_node.pause()
		$StartPause.texture_normal = play_texture
	else:
		audio_node.resume()
		$StartPause.texture_normal = pause_texture

func _display_handler():
	var songInfo = SongData.currentSong
	var ms_per_tick = songInfo.ms_per_tick
	var now = Time.get_ticks_msec()
	
	if not audio_node.playing:
		return
	
	#Display the debug color for each track
	for track in SongData.currentSong.trackData.values():
		if !audio_node.track_active.get(track.TrackType):
			#early out for muted tracks
			continue
		assert(now >= track.MidiProcess.start_time, "now < MidiProcess.start_time resulting in negative delta_ticks")
		var elapsed_ms = now - track.MidiProcess.start_time - audio_node.paused_for_ms
		var delta_ticks = float(elapsed_ms) / ms_per_tick if ms_per_tick > 0 else 0
		var level = current_levels[track.TrackType] as TrackData.Level
		var midi = track.GetMidiForLevel(level) as MidiFileParser.Track
		#BUG elapsed time goes negative on first beat of new loop after pause
		assert(elapsed_ms >= 0.0, "[DisplayHandler] elapsed time should not be negative. elapsed_ms: %s = %s - %s - %s" % [str(elapsed_ms), str(now), str(track.MidiProcess.start_time), str(audio_node.paused_for_ms)])
#		Log.print("[DisplayHandler] elapsedms: %s, delta_ticks: %s, level: %s" % [str(elapsed_ms), str(delta_ticks), str(TrackData.Level.keys()[level - 1])])
		while track.MidiProcess.event_index < midi.events.size():
			var ev = track.MidiForLevel[TrackData.Level.keys()[level - 1]].events[track.MidiProcess.event_index]
			if track.MidiProcess.delta_tick + ev.delta_ticks > delta_ticks:
				break
			#TODO should this be internal to the audio node rather than handled externally?
			track.MidiProcess.delta_tick += ev.delta_ticks
			track.MidiProcess.event_index += 1
			if ev.event_type == MidiFileParser.Event.EventType.MIDI:
				var midi_ev = ev as MidiFileParser.Midi
				# NOTE_ON status and velocity > 0
				if midi_ev.status == MidiFileParser.Midi.Status.NOTE_ON and midi_ev.velocity > 0:
					if track.TrackType in display_map.keys() and display_map[track.TrackType]:
						# show display and start timer
						display_map[track.TrackType].visible = true
						display_timers[track.TrackType] = Time.get_ticks_msec()
						#Log.print("[AudioTest] Display Handler - mapped %s, current level %s" % [str(TrackData.Tracks.keys()[track.TrackType]), str(TrackData.Level.keys()[level - 1])])
	
	# hide displays after short duration
	for track in display_map.keys():
		var t = display_timers.get(track, 0)
		if t > 0 and now - t > 120: # ms to show
			if display_map[track]:
				display_map[track].visible = false
			display_timers[track] = 0

func _process(delta):
	_display_handler()
