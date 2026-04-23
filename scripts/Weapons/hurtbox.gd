extends Area2D

@export_enum("Cooldown", "Damage", "Disable") var hurtBoxType = 0

@onready var collision = $hurtboxCollision as CollisionShape2D
@onready var timer = $hurtTimer as Timer

signal hurt(damage)

var on_cooldown = {}

func _on_area_entered(area):
	if area.is_in_group("attack"):
		assert(area.get("damage") != null, "[hurtbox] area %s does not have damage value" % [area.name])
		match (hurtBoxType):
			0: # Cooldown on a per weapon basis
				if area in on_cooldown:
					return
				Log.print("[hurtbox] Cooldown - area %s colliding with %s." % [str(name), str(area.name)])
				collision.set_deferred("disabled", true)
				on_cooldown.append(area)
				timer.start()
			1: # Single Hit
				#emit_signal("damage", area.get("damage"))
				Log.print("[hurtbox] Single Hit - area %s colliding with %s." % [str(name), str(area.name)])
			2: # Disable
				Log.print("[hurtbox] Disable - area %s colliding with %s." % [str(name), str(area.name)])
				if area.has_method("cooldown"):
					area.cooldown()
		hurt.emit(area.get("damage"))

func _on_hurt_timer_timeout():
	collision.set_deferred("disabled", false)
	on_cooldown.find()