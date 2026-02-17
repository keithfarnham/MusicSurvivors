extends Node

class_name Song

var bpm
var ms_per_beat
var beats_per_bar
var ms_per_measure
var ms_per_tick
var ticks_per_beat := 480 #aka PPQN (pulse per quarter note)
var songTitle

func _init(songName = "DefaultTitle", songBpm = 110.0, songBeatsPerBar = 4):
	songTitle = songName
	bpm = songBpm
	ms_per_beat = 60000.0 / bpm
	beats_per_bar = songBeatsPerBar
	ms_per_measure = ms_per_beat * beats_per_bar
	ms_per_tick = 60000 / (bpm * ticks_per_beat)
