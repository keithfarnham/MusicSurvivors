extends ProjectileSpawner

class_name Arp

@onready var sprite = $arpSprite as AnimatedSprite2D
@onready var projectile_spawn_offset = $projectileSpawnPos.position as Vector2
@export var speed : float = 20.0
@export var default_offset = Vector2(-7.0, -7.0)
@export var move_timer_sec = 1.0

var arpProjectile = preload("res://scenes/attacks/projectiles/ArpProjectile.tscn")

var time_since_move = 0.0
var float_offset := Vector2.ZERO
#var 
@export var float_scale := Vector2.ONE
@export var float_speed := 1.0

# arp weapon
# little floating thing follows players around firing lasers

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	sprite.play()
	spawn_projectiles()

func spawn_projectiles():
	var newInstance = arpProjectile.instantiate() as ArpProjectile
	var damage = 1
	var speed = 50.0
	var spawn_pos = global_position + projectile_spawn_offset
	var target_pos = get_nearest_target_pos()
	newInstance.initialize(damage, spawn_pos, target_pos, speed, player.position.direction_to(target_pos))
	
	# adding the projectiles as a child of the player makes them inherit movement from the parent.
	# to avoid this there is a Projectile control node in the game scene
	get_tree().current_scene.find_child("Projectiles").add_child(newInstance)

func activate_weapon():
	super.activate_weapon()
	visible = true
	
func deactivate_weapon():
	super.deactivate_weapon()
	visible = false

func _ready():
	visible = false
	position = default_offset

func _floating_movement(delta : float):
	time_since_move += delta
	
	if time_since_move >= move_timer_sec or float_offset == null:
		float_offset = Vector2(sin(Time.get_ticks_msec() * float_scale.x), sin(Time.get_ticks_msec() * float_scale.y))
		time_since_move = 0.0
	
	position = position.lerp(position + float_offset, delta * float_speed)

func _follow_movement(delta : float):
	#TODO overshoot target pos and add a momentum back to center from opposite direction of movement
	var direction := Input.get_vector("move_left","move_right","move_up","move_down")
	if direction == Vector2(0, 0):
		return
	if (direction.x < 0):
		sprite.flip_h = true
	elif (direction.x > 0):
		sprite.flip_h = false

func _process(delta):
	if !visible:
		# don't need to handle this if it's not visible
		return
	Log.print("[arp] arp ufo is at %s" % [str(position)])
	_floating_movement(delta)
	_follow_movement(delta)
