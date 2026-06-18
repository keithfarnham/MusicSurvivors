extends Node


func _on_audio_test_pressed():
	get_tree().change_scene_to_file("res://scenes/AudioTest.tscn")


func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
