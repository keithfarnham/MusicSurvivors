extends Projectile

class_name Snare

# snare weapon shoots projectile from player to nearest ne

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	# TODO handle the spawning of the projectile and setup the tracking to nearest enemy

func spawn_projectile():
	#TODO
	pass
	
func setup_path():
	#TODO
	pass
