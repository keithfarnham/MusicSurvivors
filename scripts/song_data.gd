extends Node

var currentSong : Song

enum songs {testsong, testsong2}

enum Tracks {KICK, SNARE, CYMB, SAMPLE, BASS, LEAD, ARP, CHORD}

enum Level
{
	lv1,
	lv2,
	lv3
}

var TrackAudioForLevel = {
	Tracks.KICK: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	Tracks.SNARE: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	Tracks.CYMB: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	Tracks.SAMPLE: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	Tracks.BASS: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	Tracks.LEAD: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	Tracks.ARP: {Level.lv1: "", Level.lv2: "", Level.lv3: ""},
	Tracks.CHORD: {Level.lv1: "", Level.lv2: "", Level.lv3: ""}
}

var song_data := {
	songs.testsong: Song.new("testsong", 136.0, 4),
	songs.testsong2: Song.new("testsong2", 140.0, 4)
	#songs.brango4: Song.new("brango4", 187.0, 4),
	#songs.lostinspace1: Song.new("lostinspace1", 77.0, 3)
}
