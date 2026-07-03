extends Weapon

class_name Lead
@onready var physics_body = $RigidBody2D as RigidBody2D
# lead weapon - snake that gets a velocity push toward nearest enemy each trigger

@export var force_scale : Vector2 = Vector2(1.0, 1.0)

func activate_weapon():
	super.activate_weapon()
	find_child("hitboxCollision").set_deferred("disabled", false)
	visible = true

func deactivate_weapon():
	super.deactivate_weapon()
	find_child("hitboxCollision").set_deferred("disabled", true)
	visible = false

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	physics_body.apply_force(force_scale * position.direction_to(get_nearest_target_pos()))

func _physics_process(delta):
	pass

func _ready():
	find_child("hitboxCollision").set_deferred("disabled", true)
	visible = false
