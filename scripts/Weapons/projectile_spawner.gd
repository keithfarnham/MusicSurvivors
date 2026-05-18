@abstract
extends Weapon

class_name ProjectileSpawner

@onready var player = get_tree().get_first_node_in_group("Player") as Player

# class for projectile specific vars and functions

@abstract func spawn_projectiles()

func _get_distance(pos1 : Vector2, pos2 : Vector2) -> float:
	return sqrt( pow(pos2.x - pos1.x, 2) + pow(pos2.y - pos1.y, 2) )

func get_nearest_target_pos_with_lead() -> Vector2:
	# does get_nearest_target_pos() but adds a lead to the shot based on the enemy's movement
	var nearest_enemy = get_nearest_enemy()
	return nearest_enemy.velocity

func get_nearest_target_pos() -> Vector2:
	return get_nearest_enemy().position

func get_nearest_enemy():
	var nearest_enemy
	var nearest_dist : float
	var enemyNodes = get_tree().get_nodes_in_group("Enemy")
	if enemyNodes.is_empty():
		return
	for enemyNode in enemyNodes:
		var dist = _get_distance(player.position, enemyNode.global_position)
		if nearest_dist == 0.0 or dist < nearest_dist:
			nearest_dist = dist
			nearest_enemy = enemyNode
	return nearest_enemy
