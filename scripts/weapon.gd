extends Node2D

class_name Weapon

@export var track : TrackData.Tracks
var active : bool = false
	
func activate_weapon(): #-> Weapon:
	Log.print("[player] activating weapon %s " + str(TrackData.Tracks.keys()[track]))
	active = true
