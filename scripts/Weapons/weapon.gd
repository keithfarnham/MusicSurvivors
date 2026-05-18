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
	active = true

@abstract func trigger_weapon()
	#Log.print("[weapon] %s activating" % [str(TrackData.Tracks.keys()[track])])
	#trigger.emit()
	# activate the weapon's sprite + collision
	# activate timer to disable it again
