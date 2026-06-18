extends Control

@onready var program_time_text = $VBoxValues/ProgramTimeValue
@onready var playback_time_text = $VBoxValues/AudioPlaybackValue
@onready var song_start_text = $VBoxValues/SongStartValue
@onready var loop_count_text = $VBoxValues/LoopCountValue
@onready var measure_count_text = $VBoxValues/MeasureCountValue
@onready var paused_time_text = $VBoxValues/PausedTimeValue

@onready var kick_toggle = $TrackMutes/Kick
@onready var snare_toggle = $TrackMutes/Snare
@onready var cymb_toggle = $TrackMutes/Cymb
@onready var sample_toggle = $TrackMutes/Sample
@onready var bass_toggle = $TrackMutes/Bass
@onready var lead_toggle = $TrackMutes/Lead
@onready var arp_toggle = $TrackMutes/Arp
@onready var chord_toggle = $TrackMutes/Chord

var mute_toggles = {}

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

func _on_kick_toggled(toggled_on):
	find_parent("AudioController").set_track_active(TrackData.Tracks.KICK, toggled_on)

func _on_snare_toggled(toggled_on):
	find_parent("AudioController").set_track_active(TrackData.Tracks.SNARE, toggled_on)

func _on_cymb_toggled(toggled_on):
	find_parent("AudioController").set_track_active(TrackData.Tracks.CYMB, toggled_on)

func _on_sample_toggled(toggled_on):
	find_parent("AudioController").set_track_active(TrackData.Tracks.SAMPLE, toggled_on)

func _on_bass_toggled(toggled_on):
	find_parent("AudioController").set_track_active(TrackData.Tracks.BASS, toggled_on)

func _on_lead_toggled(toggled_on):
	find_parent("AudioController").set_track_active(TrackData.Tracks.LEAD, toggled_on)

func _on_arp_toggled(toggled_on):
	find_parent("AudioController").set_track_active(TrackData.Tracks.ARP, toggled_on)

func _on_chord_toggled(toggled_on):
	find_parent("AudioController").set_track_active(TrackData.Tracks.CHORD, toggled_on)

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
