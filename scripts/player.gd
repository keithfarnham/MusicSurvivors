extends CharacterBody2D

@onready var sprite = $playerSprite as Sprite2D
#@onready var kick_sprite = $attacks/drumkick/drumkickSprite as Sprite2D
@onready var attacks = $attacks
@onready var healthBar = $CanvasLayer/GUIControl/HealthBar
@onready var xpBar = $CanvasLayer/GUIControl/XPBar
#@onready var song = $"../song" as AudioStreamPlayer

@export var hp : int = 100
@export var speed : float = 40.0

var msDeltaSinceLastUpdate = 0.0

var spectrum
var min_values = []
var max_values = []
var midi_data : MidiFileParser

#enum weapons {kick, snare, cymb, sample, bass, lead, arp, chord}
var kick_scene = preload("res://scenes/attacks/kick.tscn")
#var weapon_scenes = {weapons.kick: "res://scenes/attacks/drumkick.tscn", weapons.cymb: "", weapons.bass: ""}
var active_weapons = []

func _ready():
	midi_data = MidiFileParser.load_file("res://audio/testsong/testsong_lv1.mid")
	SongData.currentSong = SongData.song_data.get(SongData.songs.testsong)
	active_weapons.resize(SongData.Tracks.size())
	active_weapons.fill(false)
	var kickInstance = kick_scene.instantiate()
	attacks.add_child(kickInstance)
	active_weapons[SongData.Tracks.KICK] = true

func audio_process(delta):
	for track in midi_data.tracks:
		var player_process
		# storing internal player process in track data
		if "player_process" not in track.additional_data:
			track.additional_data.player_process = {"start_time" : Time.get_ticks_msec(), "delta_tick" : 0, "event_index" : 0}
			player_process = track.additional_data.player_process
		else:
			player_process = track.additional_data.player_process
			
		while player_process.event_index < track.events.size():
			var elapsed_ms = Time.get_ticks_msec() - player_process.start_time
			var delta_ticks = elapsed_ms / SongData.currentSong.ms_per_tick
			var event = track.events[player_process.event_index]
			if player_process.delta_tick + event.delta_ticks > delta_ticks:
				break
			player_process.delta_tick += event.delta_ticks
			player_process.event_index += 1
			#self.emit_signal("event", event, track)
			if event.event_type == MidiFileParser.Event.EventType.META && event.type == MidiFileParser.Meta.Type.SET_TEMPO:
				# tempo update
				#I don't think I'll need this given my songs will be consistent tempo?
				#TODO prob remove
				SongData.currentSong.ms_per_tick = event.ms_per_tick
				print("tempo now " +str(event.bpm)+ " bpm")
			if event.event_type == event.EventType.MIDI && event.note_name != '':
				var offset = event.param1 - 69
				if event.velocity > 0:
					#play_sound(event.note_name, event.frequency, event.velocity)
					print("Play "+event.note_name+" with velocity "+str(event.velocity)+" freq "+str(event.frequency))
				else:
					#play_sound(event.note_name)
					print("Stop "+event.note_name)
				
				# event.velocity <= 0 = note off
				# event.velocity > 0 = note on
				# see MidiFileParser.Midi for more information about the midi data
				pass

func _process(delta):
	#for track in midi_data.tracks:
		#for event in track:
			##Do stuff
			#print("midi event for track " + str(track))
			
	audio_process(delta)
	
	#sprite.get_material().set_shader_parameter("freq_data", fft)
	
	#midi_sync()
	#call_deferred("midi_sync")
	
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

#func midi_sync():
	#for trackIndex in range(midi_data.tracks.size()):
		#var index := 0
		#var initial_delay := midi_data.tracks[trackIndex].get_offset_in_seconds()
		#var tempo_map := midi_data.tracks[trackIndex].get_tempo_map()
		#if tempo_map.size() == 0:
			#continue
		#var us_per_beat := tempo_map[index].y
		#var time := 0.0
		##print("track " + str(trackIndex))
		#for event in midi_data.tracks[trackIndex].events:
			#time += event.delta_time
			## advance tempo map index only while the next entry exists and time passes its threshold
			#while (index + 1) < tempo_map.size() and time >= tempo_map[index + 1].x:
				#index += 1
				#us_per_beat = tempo_map[index].y
			#initial_delay += midi_data.header.convert_to_seconds(us_per_beat, event.delta_time)
			#var note_on := event as MidiData.NoteOn
			#if note_on != null:
				## TODO: wait for initial_delay and play note_on.note
				## using a timer per event for now
				#await get_tree().create_timer(initial_delay).timeout
				##trigger_weapon()
				#initial_delay = 0

func move(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if direction == Vector2(0, 0):
		return
	if (direction.x < 0):
		sprite.flip_h = true
	elif (direction.x > 0):
		sprite.flip_h = false
	velocity = direction * speed
	move_and_collide(velocity * delta)

func drumkick_attack():
	attacks.get_node("kick").visible = !attacks.get_node("kick").visible
	#var collision = attacks.get_node("kick").get_node("drumkickHitbox/hitboxCollision") as CollisionShape2D

func _on_hurtbox_hurt(damage):
	hp -= damage
	print("[player] hp: " + str(hp))
	#healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		print("[player] died")
