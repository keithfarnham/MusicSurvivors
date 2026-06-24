extends Weapon

class_name Bass

# TODO bass weapon

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
