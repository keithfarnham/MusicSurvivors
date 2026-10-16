extends Projectile

class_name LeadProjectile

func _physics_process(delta):
	#TODO setup overshot past target pos and slowdown
	position += angle*speed*delta
	
func _ready():
	pass

func trigger(target_pos : Vector2):
	Log.print("[LeadProjectile] triggering")
	
	#var dirVec = leadProjectile.position.direction_to(target_pos)
	#var distance = leadProjectile.position.distance_to(target_pos)
	#distance += distance * overshot_dist_scale
	#leadProjectile.velocity = dirVec * speed
	#leadProjectile.move_and_slide(leadProjectile.velocity * delta)
