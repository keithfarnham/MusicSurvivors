extends Control

@onready var audio_node = $AudioController as AudioController
@onready var song_choice = $SongChoice
@onready var track_mutes = $TrackMutes

#region Debug Event Handlers
@onready var kick_display = $KickRect
@onready var snare_display = $SnareRect
@onready var cymb_display = $CymbRect
@onready var sample_display = $SampleRect
@onready var bass_display = $BassRect
@onready var lead_display = $LeadRect
@onready var arp_display = $ArpRect
@onready var chord_display = $ChordRect

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
var track_muted = {} # is track muted
var mute_toggles = {}

# Track loop timers and get_length for seamless looping
var loop_timers = {}  # timers to prepare next loop

# Display mapping and timers
var display_map = {}
var display_timers = {}


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
	
	for track in TrackData.Tracks.values():
		var muted = false
		if mute_toggles[track].button_pressed:
			muted = true
		_set_track_mute(track, muted)
	
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
	_set_track_mute(TrackData.Tracks.KICK, toggled_on)

func _on_snare_toggled(toggled_on):
	_set_track_mute(TrackData.Tracks.SNARE, toggled_on)

func _on_cymb_toggled(toggled_on):
	_set_track_mute(TrackData.Tracks.CYMB, toggled_on)

func _on_sample_toggled(toggled_on):
	_set_track_mute(TrackData.Tracks.SAMPLE, toggled_on)

func _on_bass_toggled(toggled_on):
	_set_track_mute(TrackData.Tracks.BASS, toggled_on)

func _on_lead_toggled(toggled_on):
	_set_track_mute(TrackData.Tracks.LEAD, toggled_on)

func _on_arp_toggled(toggled_on):
	_set_track_mute(TrackData.Tracks.ARP, toggled_on)

func _on_chord_toggled(toggled_on):
	_set_track_mute(TrackData.Tracks.CHORD, toggled_on)

func _set_track_mute(track: TrackData.Tracks, is_muted: bool):
	if track not in audio_node.track_players:
		return
	
	var player = audio_node.stream.get_sync_stream(track)#track_players[track]
	track_muted.set(track, is_muted)
	audio_node.stream.set_sync_stream_volume(track, -80 if is_muted else 0)
#endregion Mute Toggles

#region Track level selectors
func _on_kick_lv_item_selected(index):
	current_levels[TrackData.Tracks.KICK] = index + 1 as TrackData.Level
	_update_track_synced(TrackData.Tracks.KICK)

func _on_snare_lv_item_selected(index):
	current_levels[TrackData.Tracks.SNARE] = index + 1 as TrackData.Level
	_update_track_synced(TrackData.Tracks.SNARE)

func _on_cymb_lv_item_selected(index):
	current_levels[TrackData.Tracks.CYMB] = index + 1 as TrackData.Level
	_update_track_synced(TrackData.Tracks.CYMB)

func _on_sample_lv_item_selected(index):
	current_levels[TrackData.Tracks.SAMPLE] = index + 1 as TrackData.Level
	_update_track_synced(TrackData.Tracks.SAMPLE)

func _on_bass_lv_item_selected(index):
	current_levels[TrackData.Tracks.BASS] = index + 1 as TrackData.Level
	_update_track_synced(TrackData.Tracks.BASS)

func _on_lead_lv_item_selected(index):
	current_levels[TrackData.Tracks.LEAD] = index + 1 as TrackData.Level
	_update_track_synced(TrackData.Tracks.LEAD)

func _on_arp_lv_item_selected(index):
	current_levels[TrackData.Tracks.ARP] = index + 1 as TrackData.Level
	_update_track_synced(TrackData.Tracks.ARP)

func _on_chord_lv_item_selected(index):
	current_levels[TrackData.Tracks.CHORD] = index + 1 as TrackData.Level
	_update_track_synced(TrackData.Tracks.CHORD)

func _update_track_synced(track: TrackData.Tracks):
	#update the track data
	SongData.currentSong.set_level_for_track(track, current_levels[track])

	#Get current playpack pos
	var sync_pos = 0.0
	if audio_node.playing:
		var sync_stream = audio_node.stream as AudioStreamSynchronized
		var playback_pos = audio_node.get_playback_position()
		sync_pos = playback_pos + AudioServer.get_time_since_last_mix()
	audio_node.load_track_stream(track)
	
	# Resume playback at the same position
	Log.print("[DebugScene] updating track - resuming at %ss" % [str(sync_pos)])
	call_deferred("_resume_all_synced", sync_pos)

func _resume_all_synced(playback_pos: float):
	if audio_node:
		audio_node.play(playback_pos)
		#if playback_pos > 0.0:
			#audio_node.seek()
	#for player in audio_node.track_players.values():
		#if player.stream:
			#player.play()
			#if playback_pos > 0.0:
				#player.seek(playback_pos)
#endregion Track level selectors

func _display_handler():
	var songInfo = SongData.currentSong
	var ms_per_tick = songInfo.ms_per_tick
	var now = Time.get_ticks_msec()
	
	#Display the debug color for each track
	for track in SongData.currentSong.trackData.values():
		if track_muted.get(track.TrackType):
			#early out for muted tracks
			continue
		assert(now >= track.MidiProcess.start_time, "now < MidiProcess.start_time resulting in negative delta_ticks")
		var elapsed_ms = now - track.MidiProcess.start_time
		var delta_ticks = float(elapsed_ms) / ms_per_tick if ms_per_tick > 0 else 0
		var level = current_levels[track.TrackType] as TrackData.Level
		var midi = track.GetMidiForLevel(level) as MidiFileParser.Track
		while track.MidiProcess.event_index < midi.events.size():
			var ev = track.MidiForLevel[TrackData.Level.keys()[level - 1]].events[track.MidiProcess.event_index]
			if track.MidiProcess.delta_tick + ev.delta_ticks > delta_ticks:
				break
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
						Log.print("[DebugScene] Display Handler - mapped %s, current level %s" % [str(TrackData.Tracks.keys()[track.TrackType]), str(TrackData.Level.keys()[level - 1])])
		# Check if we've reached the end of the track and loop it
		#if track.MidiProcess.event_index >= midi.events.size():
			#loop_total[TrackData.Tracks.keys()[track.TrackType]] += 1
			#print("Looping %s now on loop %s. Started at [%s] and ending at [%s], diff = %s" % \
			#[ str(TrackData.Tracks.keys()[track.TrackType]), str(loop_total[TrackData.Tracks.keys()[track.TrackType]]), str(track.MidiProcess.start_time), str(now), str(now - track.MidiProcess.start_time) ])
			## Reset to loop the MIDI track
			#track.MidiProcess.delta_tick = 0
			#track.MidiProcess.event_index = 0
			## Adjust start_time to keep sync with audio loops
			#track.MidiProcess.start_time = now 
	# hide displays after short duration
	for track in display_map.keys():
		var t = display_timers.get(track, 0)
		if t > 0 and now - t > 120: # ms to show
			if display_map[track]:
				display_map[track].visible = false
			display_timers[track] = 0

func _process(delta):
	_display_handler()
