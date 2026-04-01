extends Node

var currentSong : Song

enum Songs {testsong, testsong2}

var SongNameForDisplay = {
	Songs.testsong : "Test Song",
	Songs.testsong2 : "Test Song 2"
}

#var TrackAudioForLevel = {
	#Tracks.KICK: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	#Tracks.SNARE: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	#Tracks.CYMB: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	#Tracks.SAMPLE: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	#Tracks.BASS: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	#Tracks.LEAD: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	#Tracks.ARP: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	#Tracks.CHORD: {Level.lv1: "", Level.lv2: "", Level.lv3: ""}
#}

#var song_data := {
	#Songs.testsong: Song.new(Songs.testsong, "testsong", 136.0, 4),
	#Songs.testsong2: Song.new(Songs.testsong2, "testsong2", 140.0, 4)
	##songs.brango4: Song.new("brango4", 187.0, 4),
	##songs.lostinspace1: Song.new("lostinspace1", 77.0, 3)
#}
#var song_data = {}

#func _ready():
	#song_data.set(Songs.testsong, Song.new(Songs.testsong, "testsong", 136.0, 4))
	#song_data.set(Songs.testsong2, Song.new(Songs.testsong2, "testsong2", 140.0, 4))
