extends Node2D

@onready var audio = $Player/AudioController as AudioController
@onready var player = $Player

var current_levels = {}  # selected level for each track

func _ready():
	# right now this is setup as follows:
	# player sets weapons as active -> 
	# this (game_controller) sets the audio track active based on the active weapons on the player -> 
	# audio pushes events to player to trigger weapon
	#TODO cut out middle man here and have player directly set audio tracks active?
	for track in TrackData.Tracks.values():
		var isActive = false
		if player.is_weapon_active(track):
			isActive = true
		audio.set_track_active(track, isActive)
	
	# Initialize current levels to lv1
	for track in TrackData.Tracks.values():
		current_levels[track] = TrackData.Level.lv1
	
	# Load initial song
	audio.load_song(SongData.Songs.CosmicChill)
	
	audio.resume()
