extends Node

var bpm = 187.0
var msPerBeat = 60000.0 / bpm
var msPerMeasure = msPerBeat * 4 #song is 4/4

var songFolder = "res://songs/"
var audioFiles = []

func _ready():
	_load_audio_files(SongData.songs.testsong)
	#var stream = polyphonic
	#audio.play()
	for file in audioFiles:
		#start playing all the audio files for the level
		var index = file.find("_")
		var childName = file.substr(index + 1, file.length() - (index + 1))
		var childNode = find_child(childName) as AudioStreamPlayer
		#childNode.stream
		childNode.play_stream(load(file)) if childNode else print("Instrument node for file " + file + " not found")

func _load_audio_files(song : SongData.songs):
	audioFiles.clear()
	var songInfo = SongData.song_data.get(song) as Song
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
					_load_track_files(basePath + "/" + fileName, trackEnum, songInfo.songTitle)
			
			fileName = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error opening directory: " + basePath)
		error_string(DirAccess.get_open_error())

func _load_track_files(trackPath: String, trackEnum: int, songTitle: String):
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
						SongData.TrackAudioForLevel[trackEnum][level] = fullPath
						audioFiles.append(fullPath)
						print("Loaded: %s -> Track %d, Level %d" % [fullPath, trackEnum, level])
			
			fileName = trackDir.get_next()
		trackDir.list_dir_end()

func _parse_level(levelStr: String) -> int:
	match levelStr:
		"lv1":
			return SongData.Level.lv1
		"lv2":
			return SongData.Level.lv2
		"lv3":
			return SongData.Level.lv3
	return -1

func _parse_track(trackStr: String) -> int:
	match trackStr:
		"kick":
			return SongData.Tracks.KICK
		"snare":
			return SongData.Tracks.SNARE
		"cymb":
			return SongData.Tracks.CYMB
		"sample":
			return SongData.Tracks.SAMPLE
		"bass":
			return SongData.Tracks.BASS
		"lead":
			return SongData.Tracks.LEAD
		"arp":
			return SongData.Tracks.ARP
		"chord":
			return SongData.Tracks.CHORD
	return -1
