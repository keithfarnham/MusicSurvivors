extends Projectile

class_name SnareProjectile

func _ready():
	angle = global_position.direction_to(target_pos)
	rotation = angle.angle() + deg_to_rad(135) #TODO why is this + 135 deg here

func _physics_process(delta):
	#aLog.print("[SnareProjectile] %s is processing" % [name])
	position += angle*speed*delta

#func _init(newDmg : int, newPos : Vector2):
	#damage = newDmg
	#target_pos = newPos

func _on_projectile_spawn():
	super()
	#print("_on_projectile_spawn override hit")
