@abstract
extends Weapon

class_name ProjectileSpawner

@onready var player = get_tree().get_first_node_in_group("Player") as Player

# class for projectile specific vars and functions

@abstract func spawn_projectiles()

func _get_distance(pos1 : Vector2, pos2 : Vector2) -> float:
	return sqrt( pow(pos2.x - pos1.x, 2) + pow(pos2.y - pos1.y, 2) )

func get_nearest_target_pos():
	var nearest : Vector2
	for enemyNode in get_tree().get_nodes_in_group("Enemy"):
		var enemy_dist = _get_distance(player.position, enemyNode.position)
		if enemy_dist < nearest:
			nearest = enemy_dist
	return nearest
