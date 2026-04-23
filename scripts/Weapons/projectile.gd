@abstract
extends Weapon

class_name Projectile

# class for projectile specific vars and functions
@abstract func spawn_projectile()
@abstract func setup_path() # path will be specific to inheriting weapon type
	
func get_nearest_target() -> CharacterBody2D:
	#TODO
	return CharacterBody2D.new()

func get_random_target():
	#TODO
	pass
