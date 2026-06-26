extends Node2D

@onready var audio = $Player/AudioController as AudioController
@onready var player = $Player

var current_levels = {}  # selected level for each track

func _ready():
	# Initialize current levels to lv1
	for track in TrackData.Tracks.values():
		current_levels[track] = TrackData.Level.lv1
	
	# Load initial song
	audio.load_song(SongData.Songs.CosmicChill)
	
	audio.resume()
