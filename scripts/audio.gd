extends Node

@onready var player = $"../Player"
@onready var instrumentKick = $kick
@onready var instrumentCymb = $cymb
@onready var instrumentBass = $bass

var bpm = 187.0
var msPerBeat = 60000.0 / bpm
var msPerMeasure = msPerBeat * 4 #song is 4/4

var audioFolder = "res://audio/"
var audioFiles = []

func _ready():
	_load_audio_files()
	#var stream = polyphonic
	#audio.play()
	for file in audioFiles:
		#start playing all the audio files for the level
		var index = file.find("_")
		var childName = file.substr(index + 1, file.length() - (index + 1))
		var childNode = find_child(childName) as AudioStreamPlayer
		#childNode.stream
		childNode.play_stream(load(file)) if childNode else print("Instrument node for file " + file + " not found")

func load_files_for_song(songTitle : String):
	var songFolder = audioFolder + "/" + songTitle
	var dir = DirAccess.open(songFolder)
	#TODO unfinished func

func _load_audio_files():
	audioFiles.clear()
	for song in SongData.songs:
		var dir = DirAccess.open(audioFolder + "/" + song)
		if dir:
			dir.list_dir_begin()
			var fileName = dir.get_next()
			while fileName != "":
				if not dir.current_is_dir() and fileName.get_extension() in ["ogg"]:
					audioFiles.append(audioFolder + "/" + song + "/" + fileName)
				fileName = dir.get_next()
			dir.list_dir_end()
