extends HSplitContainer

#@onready var audio_player = $Audio/AudioStreamPlayer

var audio_files = []
var current_index = 0
var audio_folder = "res://audio"

func _ready():
	#_load_audio_files()
	pass
	#_play_current()

#func _load_audio_files():
	#audio_files.clear()
	#var dir = DirAccess.open(audio_folder)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if not dir.current_is_dir() and file_name.get_extension() in ["wav"]:
				#audio_files.append(audio_folder + "/" + file_name)
			#file_name = dir.get_next()
		#dir.list_dir_end()
#
#func _play_current():
	#if audio_files.size() > 0:
		#audio_player.stream = load(audio_files[current_index])
		#audio_player.play()
#
#func _on_prev_pressed():
	#print("prev pressed")
	#if audio_files.size() > 0:
		#current_index = (current_index - 1) % audio_files.size()
		#_play_current()
#
#func _on_next_pressed():
	#print("next pressed")
	#if audio_files.size() > 0:
		#current_index = (current_index + 1) % audio_files.size()
		#_play_current()
