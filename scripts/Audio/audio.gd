extends AudioStreamPlayer

const measure_per_loop := 8
var current_measure := 0
var current_loop := 1
var song_start := 0.0

var songFolder = "res://songs/"
var audioFiles = []
var track_players = {}
var track_lengths = {}  # length of each loaded track

var debug_printed = false

signal end_of_loop(loop)

func start_song():
	song_start = Time.get_ticks_msec()
	play()
	# start MIDI processing clock
	for track in TrackData.Tracks.values():
		print("Starting midi for %s at %s" % [str(TrackData.Tracks.keys()[track]), str(Time.get_ticks_msec())])
		SongData.currentSong.trackData[track].MidiProcess = {"start_time": Time.get_ticks_msec(), "delta_tick": 0, "event_index": 0}

func load_song(song: SongData.Songs):
	SongData.currentSong = Song.new(song, 136.0, 4)
	stop()
	
	# Load audio + midi files for all tracks and levels
	_load_audio_for_song(song)
	
	# Load and play all tracks in sync
	_load_all_tracks_synced()

func load_track_stream(track: TrackData.Tracks):
	if track not in track_players:
		return
	
	var level = SongData.currentSong.get_current_level_for_track(track)#trackData[track].CurrentLevel
	print("Loading track %s at level %s" % [str(TrackData.Tracks.keys()[track]), str(TrackData.Level.keys()[level - 1])])
	# Get the audio path from SongData
	var audio_path = SongData.currentSong.get_audio_path_for_level(track, level)#TrackAudioForLevel[track][level]
	
	if audio_path and audio_path != "":
		stream.set_sync_stream(track, load(audio_path))
		# update cached length if available
		if stream:
			track_lengths[track] = stream.get_length()
	else:
		print("ERROR - No audio file found for track %d, level %d" % [track, level - 1])
		stream = null

func _ready():
	end_of_loop.connect(_on_end_of_loop)
	
	track_players = {
		TrackData.Tracks.KICK: $kick,
		TrackData.Tracks.SNARE: $snare,
		TrackData.Tracks.CYMB: $cymb,
		TrackData.Tracks.SAMPLE: $sample,
		TrackData.Tracks.BASS: $bass,
		TrackData.Tracks.LEAD: $lead,
		TrackData.Tracks.ARP: $arp,
		TrackData.Tracks.CHORD: $chord,
	}
	
	var sync_stream = stream as AudioStreamSynchronized
	for track in track_players:
		var player = track_players.values()[track]
		sync_stream.set_sync_stream(track, player)

func _process(delta):
	if not SongData.currentSong:
		print("[audio] currentSong not setup in SongData")
		return
	#_check_track_playback()
	var now = Time.get_ticks_msec()
	var songProgress = now - song_start
	var measure = snapped(songProgress / SongData.currentSong.ms_per_measure, 1.0)
	if songProgress > SongData.currentSong.ms_per_measure and measure > current_measure:
		current_measure += 1
		print("[audio] Measure %s Loop %s - program time %s, calculated song time %s, playback time %s = %f + %f" % \
		[ str(current_measure), str(_get_current_loop()), str(now), str(songProgress), str(get_playback_position() + AudioServer.get_time_since_last_mix()), get_playback_position(), AudioServer.get_time_since_last_mix() ])
		if current_measure / measure_per_loop > current_loop:
			current_loop += 1
			end_of_loop.emit(current_loop)

func _on_end_of_loop(loop : int):
	print("Loop ended, now on loop %s" % [str(loop)])

func _check_track_playback() -> bool:
	#playback pos of tracks should all be close to each other or something bad has happened
	var pos = []
	const FAIL_THRESHOLD = 2
	for track in track_players.values():
		for compareTo in track_players.values():
			if abs( track.get_playback_position() - compareTo.get_playback_position() ) > 0.1:
				print("--- ERROR --- track playback error")
				return false
	return true

func _get_current_loop() -> int:
	return 1 if current_measure < 8 else current_measure / 8 + 1

func _load_audio_files(song : SongData.Songs):
	audioFiles.clear()
	var songInfo = SongData.currentSong as Song
	var basePath = songFolder + songInfo.songTitle + "/audio"
	var dir = DirAccess.open(basePath)
	
	if dir:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			# Check if this is a directory (track folder like "kick", "snare", etc)
			if dir.current_is_dir() and fileName != "." and fileName != "..":
				var trackEnum = _parse_track(fileName)
				if trackEnum >= 0:
					# Load all level files from this track's folder
					_load_track_files(basePath + "/" + fileName, trackEnum)
			
			fileName = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error opening directory: " + basePath)
		error_string(DirAccess.get_open_error())

func _load_track_files(trackPath: String, trackEnum: int):
	var trackDir = DirAccess.open(trackPath)
	if trackDir:
		trackDir.list_dir_begin()
		var fileName = trackDir.get_next()
		while fileName != "":
			if not trackDir.current_is_dir() and fileName.ends_with(".ogg"):
				# Parse filename: e.g., "testsong_lv1_kick.ogg"
				var withoutExt = fileName.trim_suffix(".ogg")
				var parts = withoutExt.split("_")
				
				# Find level (lv1, lv2, lv3)
				var levelStr = ""
				for part in parts:
					if part.begins_with("lv"):
						levelStr = part
						break
				
				if levelStr:
					var level = _parse_level(levelStr)
					if level >= 0:
						var fullPath = trackPath + "/" + fileName
						SongData.currentSong.set_audio_path_for_level(trackEnum, level, fullPath)
						audioFiles.append(fullPath)
						print("Loaded: %s -> Track %d, Level %d" % [fullPath, trackEnum, level])
			
			fileName = trackDir.get_next()
		trackDir.list_dir_end()

func _parse_level(levelStr: String) -> int:
	match levelStr:
		"lv1":
			return TrackData.Level.lv1
		"lv2":
			return TrackData.Level.lv2
		"lv3":
			return TrackData.Level.lv3
	return -1

func _parse_track(trackStr: String) -> int:
	match trackStr:
		"kick":
			return TrackData.Tracks.KICK
		"snare":
			return TrackData.Tracks.SNARE
		"cymb":
			return TrackData.Tracks.CYMB
		"sample":
			return TrackData.Tracks.SAMPLE
		"bass":
			return TrackData.Tracks.BASS
		"lead":
			return TrackData.Tracks.LEAD
		"arp":
			return TrackData.Tracks.ARP
		"chord":
			return TrackData.Tracks.CHORD
	return -1

func _load_audio_for_song(song: SongData.Songs):
	# Call the audio node's load function to populate SongData.TrackAudioForLevel
	_load_audio_files(song)
	
	# Debug: print what was loaded
	_debug_print_loaded_tracks()

func _load_all_tracks_synced():
	# First, load all streams without playing
	for track in TrackData.Tracks.values():
		load_track_stream(track)
	
	# Then start all players at the same time using deferred call
	call_deferred("start_song")

func _debug_print_loaded_tracks():
	print("\n=== Loaded Audio Tracks ===")
	for track in TrackData.Tracks.values():
		var track_name = TrackData.Tracks.keys()[track]
		print("Track %s (%d):" % [track_name, track])
		for level in TrackData.Level.values():
			var path = SongData.currentSong.get_audio_path_for_level(track, level)
			if path and path != "":
				print("  lv%d: %s" % [level, path])
			else:
				print("  lv%d: [EMPTY]" % [level])
