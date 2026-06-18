extends ProjectileSpawner

class_name Snare

var snareProjectile = preload("res://scenes/attacks/projectiles/SnareProjectile.tscn")

# snare weapon shoots projectile from player to nearest ne

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	spawn_projectiles()

func spawn_projectiles():
	var newInstance = snareProjectile.instantiate() as SnareProjectile
	var damage = 1
	var speed = 50.0
	newInstance.initialize(damage, player.position, get_nearest_target_pos(), speed, Vector2.ZERO)
	
	# adding the projectiles as a child of the player makes them inherit movement from the parent.
	# to avoid this there is a Projectile control node in the game scene
	get_tree().current_scene.find_child("Projectiles").add_child(newInstance)
