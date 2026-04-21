extends Area2D

@export_enum("Cooldown", "Damage", "Disable") var hurtBoxState = 0

@onready var collision = $hurtboxCollision as CollisionShape2D
@onready var timer = $hurtTimer as Timer

signal hurt(damage)

func _on_area_entered(area):
	Log.print("area %s colliding with %s" % [str(name), str(area.name)])
	if area.is_in_group("attack"):
		if area.get("damage") == null:
			return
		#print("Hurtbox hit")
		match (hurtBoxState):
			0: # Cooldown
				collision.set_deferred("disabled", true)
				timer.start()
			1: # Damage
				#emit_signal("damage", area.get("damage"))
				pass
			2: # Disable
				if area.has_method("cooldown"):
					area.cooldown()
		hurt.emit(area.get("damage"))

func _on_hurt_timer_timeout():
	collision.set_deferred("disabled", false)
