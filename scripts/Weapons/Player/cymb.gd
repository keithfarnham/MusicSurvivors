extends ProjectileSpawner

class_name Cymb

var cymbProjectile = preload("res://scenes/attacks/projectiles/CymbProjectile.tscn")

# cymb weapon shoots projectile from player in a pattern

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	spawn_projectiles()

func spawn_projectiles():
	var newInstance = cymbProjectile.instantiate() as CymbProjectile
	var damage = 1
	var speed = 100.0
	newInstance.initialize(damage, player.position, get_random_screen_pos(), speed, Vector2.ZERO)
	
	# adding the projectiles as a child of the player makes them inherit movement from the parent.
	# to avoid this there is a Projectile control node in the game scene
	get_tree().current_scene.find_child("Projectiles").add_child(newInstance)
