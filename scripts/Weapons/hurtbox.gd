extends Area2D

class_name Hurtbox

@onready var collision = $hurtboxCollision as CollisionShape2D
@onready var timer = $hurtTimer as Timer

signal hurt(damage)

var colliding_hitbox = []

func _process(delta):
	for hitbox in colliding_hitbox:
		if hitbox.get("cooldown_timer").is_stopped():
			hurt.emit(hitbox.get("damage"))
			hitbox.get("cooldown_timer").start()

func _on_area_entered(area):
	if area.is_in_group("attack"):
		assert(area.get("damage") != null, "[hurtbox] area %s does not have damage value" % [area.name])
		match area.hitbox_type:
			Hitbox.HitboxType.SINGLE:
				Log.print("[hurtbox] Single Hit - area %s colliding with %s." % [str(name), str(area.name)])
				hurt.emit(area.get("damage"))
			Hitbox.HitboxType.COOLDOWN:
				Log.print("[hurtbox] Cooldown - area %s colliding with %s." % [str(name), str(area.name)])
				colliding_hitbox.append(area)
				#TODO dmg delayed to next update might be a problem, do stuff from _process()?

func _on_area_exited(area):
	if colliding_hitbox.has(area):
		var hitbox_id = colliding_hitbox.find(area)
		colliding_hitbox[hitbox_id].remove_cooldown()
		colliding_hitbox.remove_at(hitbox_id)
		
