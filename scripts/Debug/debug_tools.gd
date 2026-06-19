extends Control

@onready var program_time_text = $VBoxValues/ProgramTimeValue as RichTextLabel
@onready var playback_time_text = $VBoxValues/AudioPlaybackValue as RichTextLabel
@onready var song_start_text = $VBoxValues/SongStartValue as RichTextLabel
@onready var loop_count_text = $VBoxValues/LoopCountValue as RichTextLabel
@onready var measure_count_text = $VBoxValues/MeasureCountValue as RichTextLabel
@onready var paused_time_text = $VBoxValues/PausedTimeValue as RichTextLabel

#region Debug Event Handlers
@onready var kick_display = $TrackOptions/Kick/KickRect
@onready var snare_display = $TrackOptions/Snare/SnareRect
@onready var cymb_display = $TrackOptions/Cymb/CymbRect
@onready var sample_display = $TrackOptions/Sample/SampleRect
@onready var bass_display = $TrackOptions/Bass/BassRect
@onready var lead_display = $TrackOptions/Lead/LeadRect
@onready var arp_display = $TrackOptions/Arp/ArpRect
@onready var chord_display = $TrackOptions/Chord/ChordRect

# UI element references
@onready var kick_toggle = $TrackOptions/Kick
@onready var snare_toggle = $TrackOptions/Snare
@onready var cymb_toggle = $TrackOptions/Cymb
@onready var sample_toggle = $TrackOptions/Sample
@onready var bass_toggle = $TrackOptions/Bass
@onready var lead_toggle = $TrackOptions/Lead
@onready var arp_toggle = $TrackOptions/Arp
@onready var chord_toggle = $TrackOptions/Chord

# Level selectors
@onready var kick_lv = $TrackOptions/KickLv as OptionButton
@onready var snare_lv = $TrackOptions/SnareLv as OptionButton
@onready var cymb_lv = $TrackOptions/CymbLv as OptionButton
@onready var sample_lv = $TrackOptions/SampleLv as OptionButton
@onready var bass_lv = $TrackOptions/BassLv as OptionButton
@onready var lead_lv = $TrackOptions/LeadLv as OptionButton
@onready var arp_lv = $TrackOptions/ArpLv as OptionButton
@onready var chord_lv = $TrackOptions/ChordLv as OptionButton
#endregion

var setup_complete := false

func update_debug_info(programTime : float, loopPlaybackTime : float, songStart : float, loopCount : int, measureCount : int, pausedTime : float):
	program_time_text.text = str(programTime)
	playback_time_text.text = str(snapped(loopPlaybackTime, 0.01))
	song_start_text.text = str(songStart)
	loop_count_text.text = str(loopCount)
	measure_count_text.text = str(measureCount)
	update_paused_info(pausedTime)
	var ms_per_loop = SongData.currentSong.ms_per_measure
	$LoopProgress.value = fmod(loopPlaybackTime, ms_per_loop) / ms_per_loop * 100

func update_paused_info(pausedTime : float):
	paused_time_text.text = str(snapped(pausedTime, 0.01))
	
func _process(delta):
	# this is done in process because I have to wait for the AudioController to instantiate
	var audio_node = get_tree().get_first_node_in_group("AudioController") as AudioController
	var player_node = get_tree().get_first_node_in_group("Player")
	if not setup_complete and audio_node != null and player_node != null:
		setup_complete = true
		audio_node.track_toggled.connect(_on_track_toggled)
		for track in TrackData.Tracks.values():
			$TrackOptions.mute_toggles[track].button_pressed = player_node.is_weapon_active(track)

func _on_track_toggled(track, is_enabled):
	Log.print("[DebugTools] %s Toggled %s " % [ str(TrackData.Tracks.keys()[track]), "enabled" if is_enabled else "disabled" ] )
	$TrackOptions.mute_toggles[track].button_pressed = is_enabled
