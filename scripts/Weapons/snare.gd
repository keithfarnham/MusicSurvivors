extends Weapon

class_name Snare

# snare weapon shoots projectile from player to nearest ne

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	
