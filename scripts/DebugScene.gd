extends Control

@onready var audio_node = $Audio
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

# Audio stream player nodes
var track_players = {}

# Track loop timers and get_length for seamless looping
var track_lengths = {}  # length of each loaded track
var loop_timers = {}  # timers to prepare next loop

# MIDI sync
var midi_parser = null
var midi_processes = []
var midi_track_map = {} # midi track index -> TrackData.Tracks enum

# Display mapping and timers
var display_map = {}
var display_timers = {}

func _ready():
	# Initialize track players dictionary, have to do it in _ready to make sure node is available
	track_players = {
		TrackData.Tracks.KICK: $Audio/kick,
		TrackData.Tracks.SNARE: $Audio/snare,
		TrackData.Tracks.CYMB: $Audio/cymb,
		TrackData.Tracks.SAMPLE: $Audio/sample,
		TrackData.Tracks.BASS: $Audio/bass,
		TrackData.Tracks.LEAD: $Audio/lead,
		TrackData.Tracks.ARP: $Audio/arp,
		TrackData.Tracks.CHORD: $Audio/chord,
	}
	
	for track in TrackData.Tracks.keys():
		track_muted.set(track, false)
	
	# Connect finished signal for each audio player to enable looping
	for track in TrackData.Tracks.values():
		if track in track_players:
			var player = track_players[track]
			# Disconnect the old finished signal if it exists
			if player.finished.is_connected(_on_player_finished.bindv([track])):
				player.finished.disconnect(_on_player_finished.bindv([track]))
	
	# Initialize current levels to lv1
	for track in TrackData.Tracks.values():
		current_levels[track] = TrackData.Level.lv1
	
	# Load initial song
	_load_song(SongData.Songs.testsong)

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
		_load_song(selected_song)


func _load_song(song: SongData.Songs):
	SongData.currentSong = Song.new(song, "testsong", 136.0, 4)
	# Stop all currently playing audio
	for player in track_players.values():
		player.stop()
	
	# Load audio + midi files for all tracks and levels
	_load_audio_for_song(song)
	
	# Load and play all tracks in sync
	_load_all_tracks_synced()


func _load_audio_for_song(song: SongData.Songs):
	# Call the audio node's load function to populate SongData.TrackAudioForLevel
	audio_node._load_audio_files(song)
	
	# Load MIDI for the song (default to lv1 MIDI)
	_load_midi_for_song(song, TrackData.Level.lv1)
	
	# Debug: print what was loaded
	_debug_print_loaded_tracks()


func _load_all_tracks_synced():
	# First, load all streams without playing
	for track in TrackData.Tracks.values():
		_load_track_stream(track)
	
	# Then start all players at the same time using deferred call
	call_deferred("_play_all_tracks_simultaneously")


func _load_track_stream(track: TrackData.Tracks):
	if track not in track_players:
		return
	
	var player = track_players[track]
	var level = current_levels[track]
	
	# Get the audio path from SongData
	var audio_path = SongData.currentSong.get_audio_path_for_level(track, level)#TrackAudioForLevel[track][level]
	
	if audio_path and audio_path != "":
		player.stream = load(audio_path)
		# update cached length if available
		if player.stream:
			track_lengths[track] = player.stream.get_length()
	else:
		print("No audio file found for track %d, level %d" % [track, level+1])
		player.stream = null


func _play_all_tracks_simultaneously():
	# Start all players at the same time
	for player in track_players.values():
		if player.stream:
			player.play()

	# start MIDI processing clock
	midi_processes.clear()
	if midi_parser:
		for i in range(midi_parser.tracks.size()):
			midi_processes.append({"start_time": Time.get_ticks_msec(), "delta_tick": 0, "event_index": 0})


func _refresh_all_tracks():
	for track in TrackData.Tracks.values():
		_play_track(track)


func _play_track(track: int):
	if track not in track_players:
		return
	
	var player = track_players[track]
	var level = current_levels[track]
	
	# Get the audio path from SongData
	var audio_path = SongData.TrackAudioForLevel[track][level]
	
	if audio_path and audio_path != "":
		player.stop()
		player.stream = load(audio_path)
		# Use a small deferred delay to ensure sync between track changes
		player.call_deferred("play")
	else:
		print("No audio file found for track %d, level %d" % [track, level+1])
		player.stop()


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
	if track not in track_players:
		return
	
	var player = track_players[track]
	track_muted.set(track, is_muted)
	player.volume_db = -80 if is_muted else 0
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
	# Update the stream for this track and resync all playback
	_load_track_stream(track)
	
	# Get the current playback position to maintain sync
	var sync_pos = 0.0
	for player in track_players.values():
		if player.playing:
			sync_pos = player.get_playback_position()
			break
	
	# Stop all and restart from the same position for sync
	for player in track_players.values():
		player.stop()
	
	# Resume playback at the same position
	call_deferred("_resume_all_synced", sync_pos)
#endregion Track level selectors

func _resume_all_synced(playback_pos: float):
	for player in track_players.values():
		if player.stream:
			player.play()
			if playback_pos > 0.0:
				player.seek(playback_pos)


func _on_player_finished(track: int):
	# Restart this player when it finishes to loop
	if track in track_players:
		var player = track_players[track]
		if player.stream:
			player.play()


func _debug_print_loaded_tracks():
	print("\n=== Loaded Audio Tracks ===")
	for track in TrackData.Tracks.values():
		var track_name = TrackData.Tracks
		print("Track %s (%d):" % [track_name, track])
		for level in TrackData.Level.values():
			var path = SongData.currentSong.get_audio_path_for_level(track, level)
			if path and path != "":
				print("  lv%d: %s" % [level, path])
			else:
				print("  lv%d: [EMPTY]" % [level])


func _load_midi_for_song(song: SongData.Songs, midi_level: TrackData.Level = TrackData.Level.lv1):
	midi_parser = null
	midi_track_map.clear()
	midi_processes.clear()
	var songInfo = SongData.currentSong as Song
	var midi_path = "res://songs/" + songInfo.songTitle + "/midi/" + songInfo.songTitle + "_lv" + str(midi_level) + ".mid"
	var f = FileAccess.open(midi_path, FileAccess.READ)
	if f:
		f.close()
		midi_parser = MidiFileParser.load_file(midi_path)
		# build track name map
		for midi_tr_index in range(midi_parser.tracks.size()):
			var midi_tr = midi_parser.tracks[midi_tr_index]
			var mapped = -1
			for ev in midi_tr.events:
				if ev.event_type == MidiFileParser.Event.EventType.META and ev.type == MidiFileParser.Meta.Type.TRACK_NAME:
					var tr_name = ""
					if ev.bytes:
						tr_name = ev.bytes.get_string_from_ascii()
					tr_name = tr_name.to_lower()
					for track in TrackData.Tracks.keys():
						if tr_name.find(TrackData.MidiTrackNameMap[TrackData.Tracks[track]]) >= 0:
							mapped = track
			midi_track_map[midi_tr_index] = mapped
	else:
		print("MIDI not found: " + midi_path)

func _display_handler():
	# find song tick length
	var songInfo = SongData.currentSong
	var ms_per_tick = songInfo.ms_per_tick
	for midi_tr_index in range(midi_parser.tracks.size()):
		var mapped = midi_track_map.get(midi_tr_index)
		if track_muted.get(mapped):
			#early out for muted tracks
			continue
		var midi_tr = midi_parser.tracks[midi_tr_index]
		var proc = null
		if midi_tr_index < midi_processes.size():
			proc = midi_processes[midi_tr_index]
		else:
			continue
		var elapsed_ms = Time.get_ticks_msec() - proc.start_time
		var delta_ticks = float(elapsed_ms) / ms_per_tick if ms_per_tick > 0 else 0
		while proc.event_index < midi_tr.events.size():
			var ev = midi_tr.events[proc.event_index]
			if proc.delta_tick + ev.delta_ticks > delta_ticks:
				break
			proc.delta_tick += ev.delta_ticks
			proc.event_index += 1
			if ev.event_type == MidiFileParser.Event.EventType.MIDI:
				var midi_ev = ev as MidiFileParser.Midi
				# NOTE_ON status and velocity > 0
				if midi_ev.status == MidiFileParser.Midi.Status.NOTE_ON and midi_ev.velocity > 0:
					
					if mapped >= 0 and mapped in display_map and display_map[mapped]:
						# show display and start timer
						display_map[mapped].visible = true
						display_timers[mapped] = Time.get_ticks_msec()
		# Check if we've reached the end of the track and loop it
		if proc.event_index >= midi_tr.events.size():
			# Reset to loop the MIDI track
			proc.delta_tick = 0
			proc.event_index = 0
			# Adjust start_time to keep sync with audio loops
			proc.start_time = Time.get_ticks_msec()
	# hide displays after short duration
	var now = Time.get_ticks_msec()
	for track in display_map.keys():
		var t = display_timers.get(track, 0)
		if t > 0 and now - t > 120: # ms to show
			if display_map[track]:
				display_map[track].visible = false
			display_timers[track] = 0

func _process(delta):
	if midi_parser == null:
		return
	_display_handler()
