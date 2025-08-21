extends Node

#class_name SongData

var currentSong : Song

enum songs {testsong, brango4, lostinspace1}

var song_data := {
	songs.testsong: Song.new("testsong", 136.0, 4)
	#songs.brango4: Song.new("brango4", 187.0, 4),
	#songs.lostinspace1: Song.new("lostinspace1", 77.0, 3)
}
