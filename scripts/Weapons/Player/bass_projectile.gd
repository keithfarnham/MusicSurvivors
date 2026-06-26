extends Projectile

class_name BassProjectile

func _ready():
	angle = global_position.direction_to(target_pos)
	rotation = angle.angle()

func _physics_process(delta):
	#Log.print("[BassProjectile] %s is processing" % [name])
	position += angle*speed*delta
	rotation += sin(Time.get_ticks_msec()) * 0.5

#func _on_projectile_spawn():
	#super()._on_projectile_spawn()

#TODO would be cool to toggle particles only when colliding with enemy
