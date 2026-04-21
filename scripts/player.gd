extends CharacterBody2D

@onready var sprite = $playerSprite as Sprite2D
@onready var attacks = $attacks
@onready var interface = $"../PlayerUI" as PlayerUI
@onready var audio_node = $"../AudioController" as AudioController

@export var hp : int = 100
@export var speed : float = 40.0

var kick_scene = preload("res://scenes/attacks/kick.tscn")
var weapons : Array[Weapon] = []

func _ready():
	weapons.resize(TrackData.Tracks.size())
	_setup_weapons()
	#weapons[TrackData.Tracks.KICK].activate_weapon()

func _process(delta):
	_attack_handler()

func _physics_process(delta):
	move(delta)

func _setup_weapons():
	# set all the weapon nodes as inactive
	for weapon_node in $attacks.get_children():
		#TODO this is just manually adding KICK as an active starting track
		# need to finish setting up the weapon scenes and remove this once i have starting weapons figured out
		if weapon_node.track == TrackData.Tracks.KICK:
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
	
func _attack_handler():
	var songInfo = SongData.currentSong
	var ms_per_tick = songInfo.ms_per_tick
	var now = Time.get_ticks_msec()
	
	# trigger the weapon for each active track
	for track in SongData.currentSong.trackData.values():
		if !audio_node.track_active.get(track.TrackType):
			#early out for inactive/muted tracks
			continue
		assert(now >= track.MidiProcess.start_time, "[player] ERROR: now < MidiProcess.start_time resulting in negative delta_ticks. This is bad.")
		var elapsed_ms = now - track.MidiProcess.start_time
		var delta_ticks = float(elapsed_ms) / ms_per_tick if ms_per_tick > 0 else 0
		#var level = current_levels[track.TrackType] as TrackData.Level
		var weapon_node = _get_weapon_node(track.TrackType)
		var level = weapon_node.current_level as TrackData.Level
		var midi = track.GetMidiForLevel(level) as MidiFileParser.Track
		while track.MidiProcess.event_index < midi.events.size():
			var ev = track.MidiForLevel[TrackData.Level.keys()[level - 1]].events[track.MidiProcess.event_index]
			if track.MidiProcess.delta_tick + ev.delta_ticks > delta_ticks:
				break
			track.MidiProcess.delta_tick += ev.delta_ticks
			track.MidiProcess.event_index += 1
			if ev.event_type == MidiFileParser.Event.EventType.MIDI:
				var midi_ev = ev as MidiFileParser.Midi
				# NOTE_ON status and velocity > 0
				if midi_ev.status == MidiFileParser.Midi.Status.NOTE_ON and midi_ev.velocity > 0:
					# trigger attack
					Log.print("[player] Attack Handler - triggered %s, current level %s" % [str(TrackData.Tracks.keys()[track.TrackType]), str(TrackData.Level.keys()[level - 1])])
					weapon_node.trigger_weapon()
	
	#TODO prob want to handle the disabling within the weapon itself so i can modify cooldowns and such
	# hide displays after short duration
	#for track in display_map.keys():
		#var t = display_timers.get(track, 0)
		#if t > 0 and now - t > 120: # ms to show
			#if display_map[track]:
				#display_map[track].visible = false
			#display_timers[track] = 0

#func drumkick_attack():
	#attacks.get_node("kick").visible = !attacks.get_node("kick").visible
	#var collision = attacks.get_node("kick").get_node("drumkickHitbox/hitboxCollision") as CollisionShape2D

func _on_hurtbox_hurt(damage):
	hp -= damage
	Log.print("[player] hp: " + str(hp))
	interface.update_hp_bar(hp)
	if hp <= 0:
		Log.print("[player] died")
