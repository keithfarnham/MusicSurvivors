extends Control

@onready var program_time_text = $DebugGrid/ProgramTimeValue
@onready var playback_time_text = $DebugGrid/AudioPlaybackValue
@onready var song_start_text = $DebugGrid/SongStartValue
@onready var song_progress_text = $DebugGrid/SongProgressValue
@onready var loop_count_text = $DebugGrid/LoopCountValue
@onready var measure_count_text = $DebugGrid/MeasureCountValue

func _ready():
	pass # Replace with function body.

func update_debug_info(programTime : float, loopPlaybackTime : float, songStart : float, songProgress : float, loopCount : int, measureCount : int):
	program_time_text.text = str(programTime)
	playback_time_text.text = str(snapped(loopPlaybackTime, 0.01))
	song_start_text.text = str(songStart)
	song_progress_text.text = str(songProgress) #TODO this isn't accurate if I pause program through godot debug tools - anyway to fix?
	loop_count_text.text = str(loopCount)
	measure_count_text.text = str(measureCount)
	
	var ms_per_loop = SongData.currentSong.ms_per_measure
	$LoopProgress.value = fmod(loopPlaybackTime, ms_per_loop) / ms_per_loop * 100
