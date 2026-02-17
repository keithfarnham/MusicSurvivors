extends Control

@onready var audio_node = $Audio
@onready var song_choice = $SongChoice
@onready var track_mutes = $TrackMutes

@onready var kick_display = $KickRect
@onready var snare_display = $SnareRect
@onready var cymb_display = $CymbRect

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

# Current song being played
var current_song: SongData.songs
var current_levels = {}  # Track which level is selected for each track

# Audio stream player nodes
var track_players = {}

# Track loop timers and get_length for seamless looping
var track_lengths = {}  # Store the length of each loaded track
var loop_timers = {}  # Timers to prepare next loop

# MIDI sync
var midi_parser = null
var midi_processes = []
var midi_track_map = {} # midi track index -> SongData.Tracks enum

# Display mapping and timers
var display_map = {}
var display_timers = {}

func _ready():
	# Initialize track players dictionary
	track_players = {
		SongData.Tracks.KICK: $Audio/kick,
		SongData.Tracks.SNARE: $Audio/snare,
		SongData.Tracks.CYMB: $Audio/cymb,
		SongData.Tracks.SAMPLE: $Audio/sample,
		SongData.Tracks.BASS: $Audio/bass,
		SongData.Tracks.LEAD: $Audio/lead,
		SongData.Tracks.ARP: $Audio/arp,
		SongData.Tracks.CHORD: $Audio/chord,
	}
	
	# Connect finished signal for each player to enable looping
	for track in SongData.Tracks.values():
		if track in track_players:
			var player = track_players[track]
			# Disconnect the old finished signal if it exists
			if player.finished.is_connected(_on_player_finished.bindv([track])):
				player.finished.disconnect(_on_player_finished.bindv([track]))
	
	# Initialize current levels to lv1 (0)
	for track in SongData.Tracks.values():
		current_levels[track] = SongData.Level.lv1
	
	# Load initial song
	_load_song(SongData.songs.testsong)

	# Prepare display map (only map ones that exist in the scene)
	display_map = {
		SongData.Tracks.KICK: kick_display,
		SongData.Tracks.SNARE: snare_display,
		SongData.Tracks.CYMB: cymb_display,
	}
	for track in display_map.keys():
		if display_map[track]:
			display_map[track].visible = false
			display_timers[track] = 0


func _on_song_choice_item_selected(index):
	var songs = SongData.songs
	var song_names = ["testsong", "testsong2"]
	
	if index >= 0 and index < song_names.size():
		var selected_song = SongData.songs[song_names[index]]
		_load_song(selected_song)


func _load_song(song: SongData.songs):
	current_song = song
	# Stop all currently playing audio
	for player in track_players.values():
		player.stop()
	
	# Load audio files for all tracks and levels
	_load_audio_for_song(song)
	
	# Load and play all tracks in sync
	_load_all_tracks_synced()


func _load_audio_for_song(song: SongData.songs):
	# Call the audio node's load function to populate SongData.TrackAudioForLevel
	audio_node._load_audio_files(song)
	# Debug: print what was loaded
	_debug_print_loaded_tracks()

	# Load MIDI for the song (default to lv1 MIDI)
	_load_midi_for_song(song, SongData.Level.lv1)


func _load_all_tracks_synced():
	# First, load all streams without playing
	for track in SongData.Tracks.values():
		_load_track_stream(track)
	
	# Then start all players at the same time using deferred call
	call_deferred("_play_all_tracks_simultaneously")


func _load_track_stream(track: int):
	if track not in track_players:
		return
	
	var player = track_players[track]
	var level = current_levels[track]
	
	# Get the audio path from SongData
	var audio_path = SongData.TrackAudioForLevel[track][level]
	
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
	for track in SongData.Tracks.values():
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


# Track mute toggles
func _on_kick_toggled(toggled_on):
	_set_track_mute(SongData.Tracks.KICK, toggled_on)

func _on_snare_toggled(toggled_on):
	_set_track_mute(SongData.Tracks.SNARE, toggled_on)

func _on_cymb_toggled(toggled_on):
	_set_track_mute(SongData.Tracks.CYMB, toggled_on)

func _on_sample_toggled(toggled_on):
	_set_track_mute(SongData.Tracks.SAMPLE, toggled_on)

func _on_bass_toggled(toggled_on):
	_set_track_mute(SongData.Tracks.BASS, toggled_on)

func _on_lead_toggled(toggled_on):
	_set_track_mute(SongData.Tracks.LEAD, toggled_on)

func _on_arp_toggled(toggled_on):
	_set_track_mute(SongData.Tracks.ARP, toggled_on)

func _on_chord_toggled(toggled_on):
	_set_track_mute(SongData.Tracks.CHORD, toggled_on)


func _set_track_mute(track: int, is_muted: bool):
	if track not in track_players:
		return
	
	var player = track_players[track]
	if is_muted:
		player.volume_db = -80  # Effectively silent
	else:
		player.volume_db = 0  # Normal volume


# Track level selectors
func _on_kick_lv_item_selected(index):
	current_levels[SongData.Tracks.KICK] = index
	_update_track_synced(SongData.Tracks.KICK)

func _on_snare_lv_item_selected(index):
	current_levels[SongData.Tracks.SNARE] = index
	_update_track_synced(SongData.Tracks.SNARE)

func _on_cymb_lv_item_selected(index):
	current_levels[SongData.Tracks.CYMB] = index
	_update_track_synced(SongData.Tracks.CYMB)

func _on_sample_lv_item_selected(index):
	current_levels[SongData.Tracks.SAMPLE] = index
	_update_track_synced(SongData.Tracks.SAMPLE)

func _on_bass_lv_item_selected(index):
	current_levels[SongData.Tracks.BASS] = index
	_update_track_synced(SongData.Tracks.BASS)

func _on_lead_lv_item_selected(index):
	current_levels[SongData.Tracks.LEAD] = index
	_update_track_synced(SongData.Tracks.LEAD)

func _on_arp_lv_item_selected(index):
	current_levels[SongData.Tracks.ARP] = index
	_update_track_synced(SongData.Tracks.ARP)

func _on_chord_lv_item_selected(index):
	current_levels[SongData.Tracks.CHORD] = index
	_update_track_synced(SongData.Tracks.CHORD)


func _update_track_synced(track: int):
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
	var track_names = {
		SongData.Tracks.KICK: "KICK",
		SongData.Tracks.SNARE: "SNARE",
		SongData.Tracks.CYMB: "CYMB",
		SongData.Tracks.SAMPLE: "SAMPLE",
		SongData.Tracks.BASS: "BASS",
		SongData.Tracks.LEAD: "LEAD",
		SongData.Tracks.ARP: "ARP",
		SongData.Tracks.CHORD: "CHORD",
	}
	
	for track in SongData.Tracks.values():
		var track_name = track_names.get(track, "UNKNOWN")
		print("Track %s (%d):" % [track_name, track])
		for level in range(3):
			var path = SongData.TrackAudioForLevel[track][level]
			if path and path != "":
				print("  lv%d: %s" % [level + 1, path])
			else:
				print("  lv%d: [EMPTY]" % [level + 1])


#func _load_midi_for_song(song: SongData.songs, midi_level: SongData.Level = SongData.Level.lv1):
	## midi_level: 0 -> lv1, 1 -> lv2, 2 -> lv3
	#midi_parser = null
	#midi_track_map.clear()
	#midi_processes.clear()
	#var songInfo = SongData.song_data.get(song) as Song
	#var midi_path = "res://songs/" + songInfo.songTitle + "/midi/" + songInfo.songTitle + "_lv" + str(midi_level + 1) + ".mid"
	#var f = FileAccess.open(midi_path, FileAccess.READ)
	#if f:
		#f.close()
		#midi_parser = MidiFileParser.load_file(midi_path)
		## build track name map
		#for i in range(midi_parser.tracks.size()):
			#var midi_tr = midi_parser.tracks[i]
			#var mapped = -1
			#for ev in midi_tr.events:
				#if ev.event_type == MidiFileParser.Event.EventType.META and ev.type == MidiFileParser.Meta.Type.TRACK_NAME:
					#var tr_name = ""
					#if ev.bytes:
						#tr_name = ev.bytes.get_string_from_ascii()
					#tr_name = tr_name.to_lower()
					#if tr_name.find("kick") >= 0:
						#mapped = SongData.Tracks.KICK
					#elif tr_name.find("snare") >= 0:
						#mapped = SongData.Tracks.SNARE
					#elif tr_name.find("cymb") >= 0 or tr_name.find("cymbal") >= 0:
						#mapped = SongData.Tracks.CYMB
					#elif tr_name.find("bass") >= 0:
						#mapped = SongData.Tracks.BASS
					#elif tr_name.find("lead") >= 0:
						#mapped = SongData.Tracks.LEAD
					#elif tr_name.find("arp") >= 0:
						#mapped = SongData.Tracks.ARP
					#elif tr_name.find("chord") >= 0:
						#mapped = SongData.Tracks.CHORD
					#elif tr_name.find("sample") >= 0:
						#mapped = SongData.Tracks.SAMPLE
					#if mapped >= 0:
						#break
			#midi_track_map[i] = mapped
	#else:
		#print("MIDI not found: " + midi_path)


func _process(_delta):
	# MIDI event processing -> update displays
	if midi_parser == null:
		return
	# find song tick length
	var songInfo = SongData.song_data.get(current_song) as Song
	var ms_per_tick = songInfo.ms_per_tick
	for ti in range(midi_parser.tracks.size()):
		var midi_tr = midi_parser.tracks[ti]
		var proc = null
		if ti < midi_processes.size():
			proc = midi_processes[ti]
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
					var mapped = midi_track_map.get(ti, -1)
					if mapped >= 0 and mapped in display_map and display_map[mapped]:
						# show display and start timer
						display_map[mapped].visible = true
						display_timers[mapped] = Time.get_ticks_msec()
	# hide displays after short duration
	var now = Time.get_ticks_msec()
	for track in display_map.keys():
		var t = display_timers.get(track, 0)
		if t > 0 and now - t > 120: # ms to show
			if display_map[track]:
				display_map[track].visible = false
			display_timers[track] = 0
