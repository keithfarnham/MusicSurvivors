@abstract
extends Node2D

class_name Weapon

@onready var player = get_tree().get_first_node_in_group("Player") as Player

var hitbox_collider_node : CollisionShape2D
@export var track : TrackData.Tracks
var active : bool = false
var current_level : TrackData.Level = TrackData.Level.lv1

signal trigger

func activate_weapon():
	Log.print("[weapon] activating weapon %s " + str(TrackData.Tracks.keys()[track]))
	# activating weapon sets the associated audio track active
	get_tree().get_first_node_in_group("AudioController").set_track_active(track, true)
	active = true

func deactivate_weapon():
	active = false
	Log.print("[weapon] deactivating weapon %s " + str(TrackData.Tracks.keys()[track]))
	get_tree().get_first_node_in_group("AudioController").set_track_active(track, false)

@abstract func trigger_weapon()

func get_nearest_target_pos() -> Vector2:
	var nearest_enemy = get_nearest_enemy()
	return get_random_screen_pos() if nearest_enemy == null else nearest_enemy.global_position
	
func get_nearest_enemy():
	var nearest_enemy
	var nearest_dist : float
	var enemyNodes = get_tree().get_nodes_in_group("Enemy")
	if enemyNodes.is_empty():
		return
	for enemyNode in enemyNodes:
		var dist = player.position.distance_to(enemyNode.global_position)
		if nearest_dist == 0.0 or dist < nearest_dist:
			nearest_dist = dist
			nearest_enemy = enemyNode
	return nearest_enemy

func get_random_screen_pos():
	var screen_size = get_viewport_rect().size
	return Vector2(randf_range(0.0, screen_size.x), randf_range(0.0, screen_size.y))

func _on_level_change(newLevel : TrackData.Level):
	current_level = newLevel
