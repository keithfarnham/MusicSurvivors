extends ProjectileSpawner

class_name Lead
var leadProjectile = preload("res://scenes/attacks/projectiles/LeadProjectile.tscn")
# lead weapon - snake that gets a velocity push toward nearest enemy each trigger

@export var force_scale : Vector2 = Vector2(1.0, 1.0)
@export_range(0.0, 1.0, 0.1) var overshot_dist_scale : float = 1.0
@export var speed : float = 20.0

var trigger_index : int = 0

func activate_weapon():
	super.activate_weapon()
	visible = true
	spawn_projectiles()

func deactivate_weapon():
	super.deactivate_weapon()
	visible = false
	var pos = player.global_position
	_cleanup_projectiles()

func trigger_weapon():
	Log.print("[%s] triggering")
	var projectile_count = $Projectiles.get_child_count()
	if trigger_index <= projectile_count:
		var nearest_target = get_nearest_enemy()
		var target_pos : Vector2
		if nearest_target != null:
			target_pos = get_nearest_target_pos()
		else:
			# if no enemies are nearby then target the player
			target_pos = player.global_position
		$Projectiles.get_child(trigger_index).trigger(target_pos)

func spawn_projectiles():
	var newInstance = leadProjectile.instantiate() as LeadProjectile
	var damage = 1
	var speed = 100.0
	newInstance.initialize(damage, player.position, get_random_screen_pos(), speed, Vector2.ZERO, 1.0, true)
	
	# lead projectiles are part of the weapon because they are persistent
	# using CanvasItem's visibility Top Level setting to force decoupled transform from parent
	$Projectiles.add_child(newInstance)


func _on_level_change(newLevel : TrackData.Level):
	#TODO on level change we need to spawn or despawn projectiles
	pass

func _cleanup_projectiles():
	for projectile in $Projectiles.get_children():
		projectile.queue_free()

func _ready():
	visible = false
