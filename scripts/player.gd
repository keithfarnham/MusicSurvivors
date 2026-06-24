extends CharacterBody2D

class_name Player

@onready var sprite = $playerSprite as Sprite2D
@onready var attacks = $attacks
@onready var interface = $PlayerUI as PlayerUI
@onready var audio_node = $AudioController as AudioController

@export var hp : int = 100
@export var speed : float = 40.0

var kick_scene = preload("res://scenes/attacks/kick.tscn")
var weapons : Array[Weapon] = []

func _ready():
	weapons.resize(TrackData.Tracks.size())
	# connect midi event signal
	audio_node.midi_event.connect(_trigger_attack)
	_setup_weapons()

func _physics_process(delta):
	move(delta)

func _setup_weapons():
	# set all the weapon nodes as inactive
	for weapon_node in $attacks.get_children():
		#TODO this is just manually adding KICK as an active starting track
		# need to finish setting up the weapon scenes and remove this once i have starting weapons figured out
		if weapon_node.track == TrackData.Tracks.KICK or weapon_node.track == TrackData.Tracks.SNARE or weapon_node.track == TrackData.Tracks.SAMPLE:
			weapon_node.activate_weapon()

func is_weapon_active(track : TrackData.Tracks) -> bool:
	for weapon_node in $attacks.get_children():
		if weapon_node.track == track and weapon_node.active:
			return true
	return false

func move(delta):
	var direction := Input.get_vector("move_left","move_right","move_up","move_down")
	if direction == Vector2(0, 0):
		return
	if (direction.x < 0):
		sprite.flip_h = true
	elif (direction.x > 0):
		sprite.flip_h = false
	velocity = direction * speed
	move_and_collide(velocity * delta)
	
func _get_weapon_node(track : TrackData.Tracks) -> Weapon:
	for weapon_node in $attacks.get_children():
		if weapon_node.track == track:
			return weapon_node
	assert(false, "[player] ERROR weapon node not found")
	return null
	
func _trigger_attack(trackType):
	# names of attacks in the Player scene need to match the MidiTrackNameMap names for this to work correctly
	attacks.find_child( TrackData.MidiTrackNameMap[trackType] ).trigger_weapon()

func _on_hurtbox_hurt(damage):
	hp -= damage
	Log.print("[player] hp: " + str(hp))
	interface.update_hp_bar(hp)
	if hp <= 0:
		Log.print("[player] died")
