extends Weapon

class_name Chord

# TODO chord weapon

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
