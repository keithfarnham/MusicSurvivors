extends Node2D

@onready var audio = $AudioController
@onready var player = $Player

var current_levels = {}  # selected level for each track

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for track in TrackData.Tracks.values():
		var isActive = false
		if player.is_weapon_active(track):
			isActive = true
		audio.set_track_active(track, isActive)
	
	# Initialize current levels to lv1
	for track in TrackData.Tracks.values():
		current_levels[track] = TrackData.Level.lv1
	
	# Load initial song
	audio.load_song(SongData.Songs.testsong)
