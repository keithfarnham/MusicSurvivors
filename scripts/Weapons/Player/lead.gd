extends Weapon

class_name Lead

# TODO lead weapon

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
