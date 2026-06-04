extends AudioStreamPlayer

class_name AudioController

@onready var Debug = $CanvasLayer/DebugInfo

var current_measure : int = 1
var current_loop : int = 1
var song_start : float = 0.0
var playback_time_sec : float = 0.0
var paused_at : float = 0.0
var paused_for_ms : float = 0.0

var audioFiles = []
var track_players = {}
var track_lengths = {}  # length of each loaded track
var track_active = {}

var sync_stream = stream as AudioStreamSynchronized

var loop_total = {}
var last_loop_start_time = {}

const songFolder = "res://songs/"

signal end_of_loop(loop)
signal midi_event(track)

func pause():
	playback_time_sec = get_playback_position() + AudioServer.get_time_since_last_mix()
	paused_at = Time.get_ticks_msec()
	stream_paused = true
	stop()
	
func resume(): 
	stream_paused = false
	start_song(playback_time_sec)

func get_playback_time_sec() -> float:
	var playback = get_playback_position()
	Log.print("Playback at %s" % [str(playback)])
	return playback

func start_song(from_position : float = 0.0):
	play(from_position)
	
	if from_position != 0.0:
		# early out if we are resuming song
		return
	
	song_start = Time.get_ticks_msec()
	paused_at = 0.0
	paused_for_ms = 0.0
	# start MIDI processing clock if we are starting from beginning
	for track in TrackData.Tracks.values():
		Log.print("[audio] Starting midi for %s at %s" % [str(TrackData.Tracks.keys()[track]), str(song_start)])
		SongData.currentSong.trackData[track].MidiProcess = {"start_time": song_start, "delta_tick": 0, "event_index": 0}

func load_song(song: SongData.Songs):
	paused_for_ms = 0.0 # clear to prevent negative elapsed_ms
	# TODO there is a perf spike when doing this, see if i can split up load_song over multiple frames via await
	Log.print("[audio] load_song loading %s" % [SongData.get_song_display_string(song)])
	SongData.currentSong = Song.new(song, SongData.get_song_bpm(song), 4)
	stop()
	
	# Load audio + midi files for all tracks and levels
	_load_audio_for_song(song)
	
	# Load and play all tracks in sync
	_load_all_tracks_synced()

func load_track_stream(track: TrackData.Tracks):
	if track not in track_players:
		return
	
	var level = SongData.currentSong.get_current_level_for_track(track)
	Log.print("[audio] Loading track %s at level %s" % [str(TrackData.Tracks.keys()[track]), str(TrackData.Level.keys()[level - 1])])
	# Get the audio path from SongData
	var audio_path = SongData.currentSong.get_audio_path_for_level(track, level)
	audio_path = audio_path.trim_suffix(".import") # files exported as resources 
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
	track_active.set(track, is_enabled)
	stream.set_sync_stream_volume(track, 0 if is_enabled else -80)
	
func set_track_level(track : TrackData.Tracks, level : TrackData.Level):
	#update the track data
	SongData.currentSong.set_level_for_track(track, level)
	load_track_stream(track)

func update_track_level(track: TrackData.Tracks, level : TrackData.Level):
	var sync_pos = 0.0
	# Get current playpack pos
	if playing:
		var playback_pos = get_playback_time_sec()
		sync_pos = playback_pos + AudioServer.get_time_since_last_mix()
	set_track_level(track, level)
	# Resume playback at the same position
	Log.print("[audio] updating track - resuming at %ss = %s + %s" % [str(sync_pos), str(get_playback_position()), str(AudioServer.get_time_since_last_mix())])
	$sfx/levelup.play() #TODO try out some different lv up sounds
	call_deferred("_resume_at", sync_pos)

func update_all_track_levels(current_levels):
	var sync_pos = 0.0
	# Get current playpack pos
	if playing:
		var playback_pos = get_playback_position()
		sync_pos = playback_pos + AudioServer.get_time_since_last_mix()
	# update all the tracks
	for track in TrackData.Tracks.values():
		set_track_level(track, current_levels[track])
	Log.print("[audio] updating all tracks - resuming at %ss. playing = %s" % [str(sync_pos), str(playing)])
	$sfx/levelup.play()
	call_deferred("_resume_at", sync_pos)

func _on_end_of_loop(loop : int, start_offset : int):
	Log.print("[audio] Loop ended, now on loop %s" % [str(loop)])
	paused_for_ms = 0.0 # reset paused_for_ms time on loop end - only need it to sync up midi in a single loop
	var now = Time.get_ticks_msec()
	for track in SongData.currentSong.trackData.values():
		if track.MidiProcess.is_empty():
			Log.print("[audio] WARNING _on_end_of_loop track's MidiProcess is empty. This might not be a real problem if it's just between loads")
			track.MidiProcess = {"start_time": Time.get_ticks_msec(), "delta_tick": 0, "event_index": 0}
		loop_total[TrackData.Tracks.keys()[track.TrackType]] = loop
		Log.print("[audio] Looping %s now on loop %s. Started at [%s] and ending at [%s], diff = %s" % \
		[ str(TrackData.Tracks.keys()[track.TrackType]), str(loop_total[TrackData.Tracks.keys()[track.TrackType]]), str(track.MidiProcess.start_time), str(now), str(now - track.MidiProcess.start_time) ])
		# Reset to loop the MIDI track
		track.MidiProcess.delta_tick = 0
		track.MidiProcess.event_index = 0
		# Adjust start_time to keep sync with audio loops
		track.MidiProcess.start_time = now# + start_offset

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
			# there were issues with the exported version not finding the .ogg files until I instead looked for the .ogg.import files
			# so, I am switching to checking the .import files and removing the .ogg.import part of the string
			if not trackDir.current_is_dir() and fileName.ends_with(".ogg.import"):
				# Parse filename: e.g., "testsong_lv1_kick.ogg.import"
				var withoutExt = fileName.left(fileName.find(".ogg.import"))
				
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
						Log.print("[audio] _load_track_files Loaded: %s -> Track %d, Level %d" % [fullPath, trackEnum, level])
			
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
	# load all streams without playing
	for track in TrackData.Tracks.values():
		load_track_stream(track)

func _resume_at(playback_pos: float):
	play(playback_pos)

func _midi_process():
	var songInfo = SongData.currentSong
	var ms_per_tick = songInfo.ms_per_tick
	
	if not playing:
		# early out if there's no audio playing
		return
	
	for track in SongData.currentSong.trackData.values():
		if !track_active.get(track.TrackType):
			# early out for muted tracks
			continue
		if track.MidiProcess.is_empty():
			#TODO find proper fix for this
			Log.print("[MidiProcess] WARNING a track's MidiProcess is empty. This might just be in between loading so it may not acutally be an issue")
			track.MidiProcess = {"start_time": Time.get_ticks_msec(), "delta_tick": 0, "event_index": 0}
		var now = Time.get_ticks_msec()
		assert(now >= track.MidiProcess.start_time, "[MidiProcess] now (%f) < MidiProcess.start_time (%f) resulting in negative delta_ticks" % [now, track.MidiProcess.start_time])
		var elapsed_ms = now - track.MidiProcess.start_time - paused_for_ms
		assert(elapsed_ms >= 0.0, "[MidiProcess] elapsed time should not be negative. elapsed_ms: %s = %s - %s - %s" % [str(elapsed_ms), str(now), str(track.MidiProcess.start_time), str(paused_for_ms)])
		var delta_ticks = float(elapsed_ms) / ms_per_tick if ms_per_tick > 0 else 0
		var level = SongData.currentSong.get_current_level_for_track(track.TrackType) as TrackData.Level
		var midi = track.GetMidiForLevel(level) as MidiFileParser.Track
		assert(midi != null, "[MidiProcess] midi for level is null. Where is the midi?")
#		Log.print("[DisplayHandler] elapsedms: %s, delta_ticks: %s, level: %s" % [str(elapsed_ms), str(delta_ticks), str(TrackData.Level.keys()[level - 1])])
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
					# send a signal out here with the track
					midi_event.emit(track.TrackType)

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
	
	if not playing and stream_paused == true:
		if paused_at > 0.0:
			paused_for_ms += delta * 1000
			#TODO might want to 'if OS.is_debug_build()' this and update_debug_info call at end of func
			Debug.update_paused_info(paused_for_ms)
		return
	
	var now = Time.get_ticks_msec()
	var playback_position = get_playback_position()
	var time_since_last_mix = AudioServer.get_time_since_last_mix()
	var loop_playback_ms = playback_time_sec * 1000 if playback_position == 0.0 else (playback_position + AudioServer.get_time_since_last_mix()) * 1000.0
	var measure = int(loop_playback_ms / SongData.currentSong.ms_per_measure) + 1
	
	#check if we are on the next measure
	if measure > current_measure:
		current_measure = measure
		Log.print("[audio] Measure %d Loop %d - program time %d, playback time %sms = %fs + %fs" % \
		[ current_measure, current_loop, now, str(loop_playback_ms), playback_position, time_since_last_mix ])
		
	#check if we've looped around from last measure to first
	var measure_per_loop = SongData.get_song_measure_per_loop(SongData.currentSong.song)
	if current_measure >= measure_per_loop and measure == 1:
		current_loop += 1
		current_measure = 1
		Log.print("[audio] Now on loop %d" % [current_loop])
		var calculated_loop_end = song_start + (current_loop * measure_per_loop * SongData.currentSong.ms_per_measure)
		var offset = calculated_loop_end - now # TODO reasses if offset is necessary, it was causing problems with midi looping
		end_of_loop.emit(current_loop, offset)
	
	Debug.update_debug_info(now, loop_playback_ms, song_start, current_loop, measure, paused_for_ms)
	_midi_process()
