extends Weapon

class_name Kick

#var snare_projectile = preload("")

@onready var active_timer = $activeTimer

var time_active_sec : float = 0.25

# kick weapon creates AOE around player for a set amount of time

func _ready():
	# set the colliders disabled on ready, colliders will be enabled when weapon is triggered
	hitbox_collider_node = find_child("hitboxCollision")
	hitbox_collider_node.set_deferred("disabled", true)

func _on_active_timeout():
	visible = false
	find_child("hitboxCollision").set_deferred("disabled", true)

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	active_timer.start(time_active_sec)
	visible = true
	find_child("hitboxCollision").set_deferred("disabled", false)
