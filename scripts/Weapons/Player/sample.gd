extends Weapon

class_name Sample

# TODO zone can scale with area

@onready var particle_node = $sampleParticles as GPUParticles2D

var distance : float = 32.0
#var radius : float = 6.0
#$sampleHitbox/hitboxCollision.shape.radius
var current_state : State = State.UP

enum State {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

func _set_state(newState : State):
	current_state = newState

func trigger_weapon():
	Log.print("[%s] triggering" % [str(TrackData.Tracks.keys()[track])])
	particle_node.emitting = true
	match current_state:
		State.UP:
			# currently UP, move to RIGHT
			position = Vector2(distance, 0.0)
			_set_state(State.RIGHT)
		State.RIGHT:
			# currently RIGHT, move to DOWN
			position = Vector2(0.0, distance)
			_set_state(State.DOWN)
		State.DOWN:
			# currently DOWN, move to LEFT
			position = Vector2(-distance, 0.0)
			_set_state(State.LEFT)
		State.LEFT:
			# current LEFT, move to UP
			position = Vector2(0.0, -distance)
			_set_state(State.UP)

func activate_weapon():
	super.activate_weapon()
	find_child("hitboxCollision").set_deferred("disabled", false)
	visible = true
	
func deactivate_weapon():
	super.deactivate_weapon()
	find_child("hitboxCollision").set_deferred("disabled", true)
	visible = false

func _ready():
	find_child("hitboxCollision").set_deferred("disabled", true)
	visible = false
