extends AudioStreamPlayer

class_name AudioController

@onready var Debug = $CanvasLayer/DebugInfo

var current_measure : int = 1
var current_loop : int = 1
var song_start : float = 0.0
var playback_time : float = 0.0

var songFolder = "res://songs/"
var audioFiles = []
var track_players = {}
var track_lengths = {}  # length of each loaded track
var track_active = {}

var sync_stream = stream as AudioStreamSynchronized

var loop_total = {}
var last_loop_start_time = {}

signal end_of_loop(loop)

func start_song():
	song_start = Time.get_ticks_msec()
	play()
	# start MIDI processing clock
	for track in TrackData.Tracks.values():
		Log.print("[audio] Starting midi for %s at %s" % [str(TrackData.Tracks.keys()[track]), str(Time.get_ticks_msec())])
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
	Log.print("[audio] Loading track %s at level %s" % [str(TrackData.Tracks.keys()[track]), str(TrackData.Level.keys()[level - 1])])
	# Get the audio path from SongData
	var audio_path = SongData.currentSong.get_audio_path_for_level(track, level)#TrackAudioForLevel[track][level]
	
	if audio_path and audio_path != "":
		stream.set_sync_stream(track, load(audio_path))
		# update cached length if available
		if stream:
			track_lengths[track] = stream.get_length()
	else:
		Log.print("[audio] ERROR - No audio file found for track %d, level %d" % [track, level - 1])
		stream = null

func set_track_active(track: TrackData.Tracks, is_enabled: bool):
	if track not in track_players:
		return
	
	var player = stream.get_sync_stream(track)
	track_active.set(track, is_enabled)
	stream.set_sync_stream_volume(track, 0 if is_enabled else -80)

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
	
	for track in TrackData.Tracks:
		loop_total.set(track, 1)
		last_loop_start_time.set(track, 0.0)
	
	for track in track_players:
		var player = track_players.values()[track]
		sync_stream.set_sync_stream(track, player)

func _process(delta):
	if not SongData.currentSong:
		Log.print("[audio] currentSong not setup in SongData")
		return
	if !playing:
		Log.print("[audio] Audio stopped playing")
	var now = Time.get_ticks_msec()
	var calculated_song_progress = now - song_start #TODO breaks if i use godot debug pause, change to a script var timer accumulating from delta

	var playback_position = get_playback_position()
	var time_since_last_mix = AudioServer.get_time_since_last_mix()
	var loop_playback_ms = (playback_position + AudioServer.get_time_since_last_mix()) * 1000.0
	var measure = int(loop_playback_ms / SongData.currentSong.ms_per_measure) + 1
	
	#check if we are on the next measure
	if measure > current_measure:
		current_measure = measure
		Log.print("[audio] Measure %d Loop %d - program time %d, calculated song time %d, playback time %s = %f + %f" % \
		[ current_measure, current_loop, now, calculated_song_progress, str(loop_playback_ms), playback_position, time_since_last_mix ])
		
	#check if we've looped around from last measure MEASURE_PER_LOOP to first
	if current_measure >= SongData.MEASURE_PER_LOOP and measure == 1:
		current_loop += 1
		current_measure = 1
		Log.print("[audio] Now on loop %d" % [current_loop])
		var calculated_loop_end = song_start + (current_loop * SongData.MEASURE_PER_LOOP * SongData.currentSong.ms_per_measure)
		var offset = calculated_loop_end - now # TODO reasses if offset is necessary, it was causing problems with midi looping
		end_of_loop.emit(current_loop, offset)
	
	Debug.update_debug_info(now, loop_playback_ms, song_start, calculated_song_progress, current_loop, measure)

func _on_end_of_loop(loop : int, start_offset : int):
	Log.print("[audio] Loop ended, now on loop %s" % [str(loop)])
	var now = Time.get_ticks_msec()
	for track in SongData.currentSong.trackData.values():
		loop_total[TrackData.Tracks.keys()[track.TrackType]] = loop
		Log.print("[audio] Looping %s now on loop %s. Started at [%s] and ending at [%s], diff = %s" % \
		[ str(TrackData.Tracks.keys()[track.TrackType]), str(loop_total[TrackData.Tracks.keys()[track.TrackType]]), str(track.MidiProcess.start_time), str(now), str(now - track.MidiProcess.start_time) ])
		# Reset to loop the MIDI track
		track.MidiProcess.delta_tick = 0
		track.MidiProcess.event_index = 0
		# Adjust start_time to keep sync with audio loops
		track.MidiProcess.start_time = now# + start_offset

#func _check_track_playback() -> bool:
	##playback pos of tracks should all be close to each other or something bad has happened
	#var pos = []
	#const FAIL_THRESHOLD = 2
	#for track in track_players.values():
		#for compareTo in track_players.values():
			#if abs( track.get_playback_position() - compareTo.get_playback_position() ) > 0.1:
				#print("--- ERROR --- track playback error")
				#return false
	#return true

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
		Log.print("[audio] Error opening directory: " + basePath)
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
						Log.print("[audio] Loaded: %s -> Track %d, Level %d" % [fullPath, trackEnum, level])
			
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
	Log.debug_print_loaded_tracks()

func _load_all_tracks_synced():
	# First, load all streams without playing
	for track in TrackData.Tracks.values():
		load_track_stream(track)
	
	# Then start all players at the same time using deferred call
	call_deferred("start_song")
