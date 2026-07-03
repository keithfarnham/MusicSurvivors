@abstract
extends Node2D

class_name Projectile

#@onready var player = get_tree().get_first_node_in_group("Player") as Player

enum Types {
	SINGLE_POS,
	SINGLE_TARGET,
	BEAM
}

enum ProjectileState {
	ON_SPAWN,
	FLYING,
	FALLOFF,
	ON_DESPAWN
}

var start_position : Vector2
var hits_before_despawn : int = 1
var target_pos : Vector2
var speed : float = 1.0
var damage : int
var angle : Vector2 = Vector2.ZERO
var spread : float
var turn_speed : float = 1.0 #TODO setup turnspeed

var time_offscreen : float = 0.0 #TODO setup time offscreen to auto despawn
const OFFSCREEN_DESPAWN_TIME := 1.0

var distance_to_despawn : float
var distance_to_falloff : float
var falloff_distance : float

var homing_enabled : bool = false
var homing_power : float = 1.0

var screenbounce_enabled : bool = false

var path : Path2D #TODO investigate for more complicated bullet pathing

var state : ProjectileState

func _set_state(newState : ProjectileState):
	Log.print("[projectile] setting state from %s to %s" % [ str(ProjectileState.keys()[state]), str(ProjectileState.keys()[newState]) ])
	state = newState

#region state machine functions
# basic fuctions for each state. These happen for EVERY projectile unless overridden 
# call base func in override via super()
func _on_projectile_spawn():
	# do anything needed on spawn here for every projectile
	_set_state(ProjectileState.FLYING)

func _on_projectile_flying():
	if distance_to_falloff != 0.0 and start_position.distance_to(position) >= distance_to_falloff:
		_set_state(ProjectileState.FALLOFF)
	if distance_to_despawn != 0.0 and start_position.distance_to(position) >= distance_to_despawn:
		_set_state(ProjectileState.ON_DESPAWN)

func _on_projectile_falloff():
	if start_position.distance_to(position) >= distance_to_falloff + falloff_distance:
		_set_state(ProjectileState.ON_DESPAWN)

func _on_projectile_despawn():
	# stuff to do when the projectile is gonna disappear (explosion effects, shooting other projectiles, etc.)
	#Log.print("[projectile] removing " + str(name))
	queue_free()
#endregion
	
func _process(delta):
	#if offscreen:
	#	time_offscreen += delta
	#	if time_offscreen >= OFFSCREEN_DESPAWN_TIME:
	#		_set_state(ProjectileState.OnDespawn)
	match state:
		ProjectileState.ON_SPAWN:
			_on_projectile_spawn()
		ProjectileState.FLYING:
			_on_projectile_flying()
		ProjectileState.FALLOFF:
			_on_projectile_falloff()
		ProjectileState.ON_DESPAWN:
			_on_projectile_despawn()

func initialize(newDmg : int, newStartPos : Vector2, newTargetPos : Vector2, newSpeed : float, newAngle := Vector2.ZERO, newTurnSpeed := 1.0):
	damage = newDmg
	# set both cached and current start position
	start_position = newStartPos
	position = newStartPos
	target_pos = newTargetPos
	speed = newSpeed
#	rotate(angle.angle_to(newAngle))
	turn_speed = newTurnSpeed
