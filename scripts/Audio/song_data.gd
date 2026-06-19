extends Node

var currentSong : Song

enum Songs {
	AnotherAudioAdventure,
	BreakingBreath,
	CosmicChill,
	testsong
	}

var song_data := {
	# Songs.Enum: [Display String, BPM, Measure Per Loop]
	Songs.testsong: ["Test Song", 136.0, 8],
	Songs.AnotherAudioAdventure: ["Another Audio Adventure", 136.0, 8],
	Songs.BreakingBreath: ["Breaking Breath", 146.0, 8],
	Songs.CosmicChill: ["Cosmic Chill", 121.0, 16]

}

func get_song_display_string(song : Songs):
	return song_data[song][0]

func get_song_bpm(song : Songs):
	return song_data[song][1]

func get_song_measure_per_loop(song : Songs):
	return song_data[song][2]
