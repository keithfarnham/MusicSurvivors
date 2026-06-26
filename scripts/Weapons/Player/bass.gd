extends ProjectileSpawner

class_name Bass

var bassProjectile = preload("res://scenes/attacks/projectiles/BassProjectile.tscn")

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])

func spawn_projectiles():
	var newInstance = bassProjectile.instantiate() as BassProjectile
	var damage = 1
	var speed = 50.0
	newInstance.initialize(damage, player.position, get_nearest_target_pos(), speed, Vector2.ZERO)
	
	# adding the projectiles as a child of the player makes them inherit movement from the parent.
	# to avoid this there is a Projectile control node in the game scene
	get_tree().current_scene.find_child("Projectiles").add_child(newInstance)
