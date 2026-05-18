extends Control

@onready var program_time_text = $VBoxValues/ProgramTimeValue
@onready var playback_time_text = $VBoxValues/AudioPlaybackValue
@onready var song_start_text = $VBoxValues/SongStartValue
@onready var loop_count_text = $VBoxValues/LoopCountValue
@onready var measure_count_text = $VBoxValues/MeasureCountValue
@onready var paused_time_text = $VBoxValues/PausedTimeValue

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
