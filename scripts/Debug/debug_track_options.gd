extends GridContainer

class_name DebugTrackOptions

#region Debug Event Handlers
@onready var kick_display = $Kick/KickRect
@onready var snare_display = $Snare/SnareRect
@onready var cymb_display = $Cymb/CymbRect
@onready var sample_display = $Sample/SampleRect
@onready var bass_display = $Bass/BassRect
@onready var lead_display = $Lead/LeadRect
@onready var arp_display = $Arp/ArpRect
@onready var chord_display = $Chord/ChordRect

# UI element references
@onready var kick_toggle = $Kick
@onready var snare_toggle = $Snare
@onready var cymb_toggle = $Cymb
@onready var sample_toggle = $Sample
@onready var bass_toggle = $Bass
@onready var lead_toggle = $Lead
@onready var arp_toggle = $Arp
@onready var chord_toggle = $Chord

# Level selectors
@onready var kick_lv = $KickLv as OptionButton
@onready var snare_lv = $SnareLv as OptionButton
@onready var cymb_lv = $CymbLv as OptionButton
@onready var sample_lv = $SampleLv as OptionButton
@onready var bass_lv = $BassLv as OptionButton
@onready var lead_lv = $LeadLv as OptionButton
@onready var arp_lv = $ArpLv as OptionButton
@onready var chord_lv = $ChordLv as OptionButton
#endregion

var current_levels = {}  # selected level for each track
var mute_toggles = {}
var lvl_selectors = {}

# Display mapping and timers
var display_map = {}
var display_timers = {}

signal active_toggled(isActive)

#region Mute Toggles
# Debug Toggles -> Weapon -> Audio
# if player doesn't exist (debug mode) just enable the track directly
func _on_kick_toggled(toggled_on):
	if get_tree().get_first_node_in_group("Player") != null:
		var weapon_node = get_tree().get_first_node_in_group("Player").find_child("kick") as Kick
		weapon_node.activate_weapon() if toggled_on else weapon_node.deactivate_weapon()
	else:
		get_tree().get_first_node_in_group("AudioController").set_track_active(TrackData.Tracks.KICK, toggled_on)

func _on_snare_toggled(toggled_on):
	if get_tree().get_first_node_in_group("Player") != null:	
		var weapon_node = get_tree().get_first_node_in_group("Player").find_child("snare") as Snare
		weapon_node.activate_weapon() if toggled_on else weapon_node.deactivate_weapon()
	else:
		get_tree().get_first_node_in_group("AudioController").set_track_active(TrackData.Tracks.SNARE, toggled_on)

func _on_cymb_toggled(toggled_on):
	if get_tree().get_first_node_in_group("Player") != null:
		var weapon_node = get_tree().get_first_node_in_group("Player").find_child("cymb") as Cymb
		weapon_node.activate_weapon() if toggled_on else weapon_node.deactivate_weapon()
	else:
		get_tree().get_first_node_in_group("AudioController").set_track_active(TrackData.Tracks.CYMB, toggled_on)

func _on_sample_toggled(toggled_on):
	if get_tree().get_first_node_in_group("Player") != null:
		var weapon_node = get_tree().get_first_node_in_group("Player").find_child("sample") as Sample
		weapon_node.activate_weapon() if toggled_on else weapon_node.deactivate_weapon()
	else:
		get_tree().get_first_node_in_group("AudioController").set_track_active(TrackData.Tracks.SAMPLE, toggled_on)

func _on_bass_toggled(toggled_on):
	if get_tree().get_first_node_in_group("Player") != null:
		var weapon_node = get_tree().get_first_node_in_group("Player").find_child("bass") as Bass
		weapon_node.activate_weapon() if toggled_on else weapon_node.deactivate_weapon()
	else:
		get_tree().get_first_node_in_group("AudioController").set_track_active(TrackData.Tracks.BASS, toggled_on)

func _on_lead_toggled(toggled_on):
	if get_tree().get_first_node_in_group("Player") != null:
		var weapon_node = get_tree().get_first_node_in_group("Player").find_child("lead") as Lead
		weapon_node.activate_weapon() if toggled_on else weapon_node.deactivate_weapon()
	else:
		get_tree().get_first_node_in_group("AudioController").set_track_active(TrackData.Tracks.LEAD, toggled_on)

func _on_arp_toggled(toggled_on):
	if get_tree().get_first_node_in_group("Player") != null:
		var weapon_node = get_tree().get_first_node_in_group("Player").find_child("arp") as Arp
		weapon_node.activate_weapon() if toggled_on else weapon_node.deactivate_weapon()
	else:
		get_tree().get_first_node_in_group("AudioController").set_track_active(TrackData.Tracks.ARP, toggled_on)

func _on_chord_toggled(toggled_on):
	if get_tree().get_first_node_in_group("Player") != null:
		var weapon_node = get_tree().get_first_node_in_group("Player").find_child("chord") as Chord
		weapon_node.activate_weapon() if toggled_on else weapon_node.deactivate_weapon()
	else:
		get_tree().get_first_node_in_group("AudioController").set_track_active(TrackData.Tracks.CHORD, toggled_on)
#endregion

#region Track level selectors
func _on_kick_lv_item_selected(index):
	current_levels[TrackData.Tracks.KICK] = index + 1 as TrackData.Level
	active_toggled.emit(false)
	get_tree().get_first_node_in_group("AudioController").update_track_level(TrackData.Tracks.KICK, current_levels[TrackData.Tracks.KICK])

func _on_snare_lv_item_selected(index):
	current_levels[TrackData.Tracks.SNARE] = index + 1 as TrackData.Level
	active_toggled.emit(false)
	get_tree().get_first_node_in_group("AudioController").update_track_level(TrackData.Tracks.SNARE, current_levels[TrackData.Tracks.SNARE])

func _on_cymb_lv_item_selected(index):
	current_levels[TrackData.Tracks.CYMB] = index + 1 as TrackData.Level
	active_toggled.emit(false)
	get_tree().get_first_node_in_group("AudioController").update_track_level(TrackData.Tracks.CYMB, current_levels[TrackData.Tracks.CYMB])

func _on_sample_lv_item_selected(index):
	current_levels[TrackData.Tracks.SAMPLE] = index + 1 as TrackData.Level
	active_toggled.emit(false)
	get_tree().get_first_node_in_group("AudioController").update_track_level(TrackData.Tracks.SAMPLE, current_levels[TrackData.Tracks.SAMPLE])

func _on_bass_lv_item_selected(index):
	current_levels[TrackData.Tracks.BASS] = index + 1 as TrackData.Level
	active_toggled.emit(false)
	get_tree().get_first_node_in_group("AudioController").update_track_level(TrackData.Tracks.BASS, current_levels[TrackData.Tracks.BASS])

func _on_lead_lv_item_selected(index):
	current_levels[TrackData.Tracks.LEAD] = index + 1 as TrackData.Level
	active_toggled.emit(false)
	get_tree().get_first_node_in_group("AudioController").update_track_level(TrackData.Tracks.LEAD, current_levels[TrackData.Tracks.LEAD])

func _on_arp_lv_item_selected(index):
	current_levels[TrackData.Tracks.ARP] = index + 1 as TrackData.Level
	active_toggled.emit(false)
	get_tree().get_first_node_in_group("AudioController").update_track_level(TrackData.Tracks.ARP, current_levels[TrackData.Tracks.ARP])

func _on_chord_lv_item_selected(index):
	current_levels[TrackData.Tracks.CHORD] = index + 1 as TrackData.Level
	active_toggled.emit(false)
	get_tree().get_first_node_in_group("AudioController").update_track_level(TrackData.Tracks.CHORD, current_levels[TrackData.Tracks.CHORD])
#endregion

func _ready():
	mute_toggles = {
		TrackData.Tracks.KICK: kick_toggle,
		TrackData.Tracks.SNARE: snare_toggle,
		TrackData.Tracks.CYMB: cymb_toggle,
		TrackData.Tracks.SAMPLE: sample_toggle,
		TrackData.Tracks.BASS: bass_toggle,
		TrackData.Tracks.LEAD: lead_toggle,
		TrackData.Tracks.ARP: arp_toggle,
		TrackData.Tracks.CHORD: chord_toggle,
	}
	
	lvl_selectors = {
		TrackData.Tracks.KICK: kick_lv,
		TrackData.Tracks.SNARE: snare_lv,
		TrackData.Tracks.CYMB: cymb_lv,
		TrackData.Tracks.SAMPLE: sample_lv,
		TrackData.Tracks.BASS: bass_lv,
		TrackData.Tracks.LEAD: lead_lv,
		TrackData.Tracks.ARP: arp_lv,
		TrackData.Tracks.CHORD: chord_lv,
	}
	# Prepare display map
	display_map = {
		TrackData.Tracks.KICK: kick_display,
		TrackData.Tracks.SNARE: snare_display,
		TrackData.Tracks.CYMB: cymb_display,
		TrackData.Tracks.SAMPLE: sample_display,
		TrackData.Tracks.BASS: bass_display,
		TrackData.Tracks.LEAD: lead_display,
		TrackData.Tracks.ARP: arp_display,
		TrackData.Tracks.CHORD: chord_display
	}
	# Initialize current levels to lv1
	for track in TrackData.Tracks.values():
		current_levels[track] = TrackData.Level.lv1
	
	# Initialize display map
	for track in display_map.keys():
		if display_map[track]:
			display_map[track].visible = false
			display_timers[track] = 0
