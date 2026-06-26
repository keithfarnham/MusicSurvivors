@abstract
extends Node2D

class_name Weapon

#@onready var hitbox_collider_node = $Hitbox/hitboxCollision
var hitbox_collider_node : CollisionShape2D
@export var track : TrackData.Tracks
var active : bool = false
var current_level : TrackData.Level = TrackData.Level.lv1

signal trigger

func activate_weapon():
	Log.print("[weapon] activating weapon %s " + str(TrackData.Tracks.keys()[track]))
	# activating weapon sets the associated audio track active
	get_tree().get_first_node_in_group("AudioController").set_track_active(track, true)
	active = true

func deactivate_weapon():
	active = false
	Log.print("[weapon] deactivating weapon %s " + str(TrackData.Tracks.keys()[track]))
	get_tree().get_first_node_in_group("AudioController").set_track_active(track, false)

@abstract func trigger_weapon()
