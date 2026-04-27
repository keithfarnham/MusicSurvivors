extends Area2D

class_name Hitbox

@onready var collision = $hitboxCollision as CollisionShape2D
@onready var cooldown_timer = $hitTimer as Timer

@export var hitbox_type : HitboxType
@export var damage = 1

enum HitboxType {
	Single, # does a single hit of damage to target
	Cooldown, # damage over time on a cooldown while colliding with target
}

func disable():
	collision.set_deferred("disabled", true)

func cooldown():
	#collision.set_deferred("disabled", true)
	cooldown_timer.start()

func _on_hit_timer_timeout():
	collision.set_deferred("disabled", false)

func remove_cooldown():
	cooldown_timer.stop()
