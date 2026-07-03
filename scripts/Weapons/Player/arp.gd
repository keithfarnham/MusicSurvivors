extends Weapon

class_name Arp

# TODO arp weapon
# little floating thing follows players around firing lasers

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])

func spawn_projectiles():
	#TODO
	pass
	
func setup_path():
	#TODO
	pass
