extends Weapon

class_name Lead
@onready var physics_body = $leadProjectile as RigidBody2D
# lead weapon - snake that gets a velocity push toward nearest enemy each trigger

@export var force_scale : Vector2 = Vector2(1.0, 1.0)
#@export var max_scale : Vector2 = Vector2

func activate_weapon():
	super.activate_weapon()
	find_child("hitboxCollision").set_deferred("disabled", false)
	visible = true

func deactivate_weapon():
	super.deactivate_weapon()
	find_child("hitboxCollision").set_deferred("disabled", true)
	visible = false
	var pos = player.global_position

func trigger_weapon():
	var nearest_target = get_nearest_enemy()
	var target_pos
	if nearest_target != null:
		target_pos = get_nearest_target_pos()
	else:
		# if no enemies are nearby then target the player
		target_pos = player.global_position
	var dir = physics_body.global_position.direction_to(target_pos)
	var scale = force_scale * physics_body.global_position.distance_to(target_pos)
	Log.print("[%s] triggering at %s scaled by %s " % [str(TrackData.Tracks.keys()[track]), str(target_pos), str(scale)])
	physics_body.apply_impulse(scale * dir)

func _ready():
	find_child("hitboxCollision").set_deferred("disabled", true)
	visible = false
