extends Projectile

class_name CymbProjectile

func _ready():
	angle = global_position.direction_to(target_pos)
	rotation = angle.angle() + deg_to_rad(90)

func _physics_process(delta):
	#aLog.print("[SnareProjectile] %s is processing" % [name])
	position += angle*speed*delta
	rotation += sin(Time.get_ticks_msec()) * 0.5

func _on_projectile_spawn():
	super()
	#print("_on_projectile_spawn override hit")

#TODO would be cool to toggle particles only when colliding with enemy
