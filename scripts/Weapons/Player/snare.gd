extends ProjectileSpawner

class_name Snare

var snareProjectile = preload("res://scenes/attacks/projectiles/SnareProjectile.tscn")

# snare weapon shoots projectile from player to nearest ne

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	spawn_projectiles()

func spawn_projectiles():
	var newInstance = snareProjectile.instantiate() as SnareProjectile
	#TODO not final values here
	newInstance.angle = Vector2.ZERO
	newInstance.damage = 1
	newInstance.speed = 100.0
	newInstance.target_pos = get_nearest_target_pos()
	add_child(newInstance)
