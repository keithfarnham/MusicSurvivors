extends CharacterBody2D

@onready var sprite = $playerSprite as Sprite2D
#@onready var kick_sprite = $attacks/drumkick/drumkickSprite as Sprite2D
@onready var attacks = $attacks
@onready var healthBar = $CanvasLayer/GUIControl/HealthBar
@onready var xpBar = $CanvasLayer/GUIControl/XPBar
#@onready var song = $"../song" as AudioStreamPlayer

@export var hp = 100
@export var speed = 40.0

var msDeltaSinceLastUpdate = 0.0

var spectrum
var min_values = []
var max_values = []
var midi_data : MidiData = load("res://audio/testsong/testsong_lv1.mid")
const VU_COUNT = 100
const FREQ_MAX = 10000.0
const MIN_DB = 60
const ANIMATION_SPEED = 0.1
const HEIGHT_SCALE = 100.0

#enum weapons {kick, snare, cymb, sample, bass, lead, arp, chord}
var kick_scene = preload("res://scenes/attacks/kick.tscn")
#var weapon_scenes = {weapons.kick: "res://scenes/attacks/drumkick.tscn", weapons.cymb: "", weapons.bass: ""}
var active_weapons = []

func _ready():
	if AudioServer.get_bus_effect_count(0) > 0:
		spectrum = AudioServer.get_bus_effect_instance(0, 0)
	else:
		assert("No effects found on bus 0. Please add an effect.")
		spectrum = null
	min_values.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.resize(VU_COUNT)
	max_values.fill(0.0)
	active_weapons.resize(SongData.tracks.size())
	active_weapons.fill(false)
	var kickInstance = kick_scene.instantiate()
	attacks.add_child(kickInstance)
	active_weapons[SongData.tracks.kick] = true

func _process(delta):
	var prev_hz = 0
	var data = []
	for i in range(1, VU_COUNT + 1):
		var hz = i * FREQ_MAX / VU_COUNT
		var f = spectrum.get_magnitude_for_frequency_range(prev_hz, hz)
		var energy = clamp((MIN_DB + linear_to_db(f.length())) / MIN_DB, 0.0, 1.0)
		data.append(energy * HEIGHT_SCALE)
		prev_hz = hz
	for i in range(VU_COUNT):
		if data[i] > max_values[i]:
			max_values[i] = data[i]
		else:
			max_values[i] = lerp(max_values[i], data[i], ANIMATION_SPEED)
		if data[i] <= 0.0:
			min_values[i] = lerp(min_values[i], 0.0, ANIMATION_SPEED)
	var fft = []
	for i in range(VU_COUNT):
		fft.append(lerp(min_values[i], max_values[i], ANIMATION_SPEED))
	#sprite.get_material().set_shader_parameter("freq_data", fft)
	
	#midi_sync()
	call_deferred("midi_sync")
	
	#msDeltaSinceLastUpdate += delta * 1000.0
	#if SongData.currentSong == null:
		#print("Error: No Song Playing")
	#elif (msDeltaSinceLastUpdate >= SongData.currentSong.msPerBeat):
		##TODO this will desync over time, should calc the diff between expected MS for the beat and the actual delta
		#msDeltaSinceLastUpdate = 0.0
		#for weapon in weapons:
			#if active_weapons[int(weapon)]:
				#match(weapon):
					#weapons.kick:
						#drumkick_attack()

func _physics_process(delta):
	move(delta)

func midi_sync():
	var index := 0
	var initial_delay := midi_data.tracks[0].get_offset_in_seconds()
	var tempo_map: Array[Vector2i]
	var us_per_beat
	var time := 0.0
	for trackIndex in midi_data.tracks.size():
		var track = trackIndex as SongData.tracks
		tempo_map = midi_data.tracks[trackIndex].get_tempo_map()
		us_per_beat = tempo_map[index].y
		print("track " + str(track))
		for event in midi_data.tracks[trackIndex].events:
			time += event.delta_time
			while time >= tempo_map[index].x:
				index += 1
				us_per_beat = tempo_map[index].y
			initial_delay += midi_data.header.convert_to_seconds(us_per_beat, event.delta_time)
			var note_on := event as MidiData.NoteOn
			if note_on != null:
				# TODO: wait for inital_delay and play note_on.note
				#idk if spamming the timer create is a great thing to do, might need to more properly integrate this into the _process() call
				await get_tree().create_timer(initial_delay).timeout
				#trigger_weapon()
				initial_delay = 0

func move(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if (direction.x < 0):
		sprite.flip_h = true
	elif (direction.x > 0):
		sprite.flip_h = false
	velocity = direction * speed
	move_and_collide(velocity * delta)

func drumkick_attack():
	attacks.get_node("kick").visible = !attacks.get_node("kick").visible
	var collision = attacks.get_node("kick").get_node("drumkickHitbox/hitboxCollision") as CollisionShape2D

func _on_hurtbox_hurt(damage):
	hp -= damage
	print("[player] hp: " + str(hp))
	#healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		print("[player] died")
