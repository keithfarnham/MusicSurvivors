extends Area2D

@onready var collision = $hitboxCollision as CollisionShape2D
@onready var timer = $hitTimer as Timer

@export var damage = 1

func disable():
	collision.set_deferred("disabled", true)

func cooldown():
	collision.set_deferred("disabled", true)
	timer.start()

func _on_hit_timer_timeout():
	collision.set_deferred("disabled", false)
