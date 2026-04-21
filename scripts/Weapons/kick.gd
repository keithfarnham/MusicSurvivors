extends Weapon

class_name Kick

@onready var active_timer = $activeTimer
@onready var hitbox = $Hitbox

var time_active_sec : float = 0.25

# kick weapon creates AOE around player for a set amount of time

func _on_active_timeout():
	visible = false
	hitbox.get_node("hitboxCollision").set_deferred("disabled", true)

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	active_timer.start(time_active_sec)
	visible = true
	hitbox.get_node("hitboxCollision").set_deferred("disabled", false)
