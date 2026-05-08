extends ProjectileSpawner

class_name Cymb

# cymb weapon shoots projectile from player in a pattern

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	# TODO handle the spawning of the projectile

func spawn_projectiles():
	#TODO
	pass
	
func setup_path():
	#TODO
	pass
