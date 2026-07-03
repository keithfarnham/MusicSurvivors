extends Projectile

class_name SnareProjectile

func _physics_process(delta):
	#Log.print("[SnareProjectile] %s is processing" % [name])
	position += angle*speed*delta

func _on_projectile_spawn():
	super()
	#print("_on_projectile_spawn override hit")

func _ready():
	angle = global_position.direction_to(target_pos)
	rotation = angle.angle() + deg_to_rad(90)
