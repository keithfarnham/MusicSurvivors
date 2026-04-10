extends CharacterBody2D

@onready var sprite = $sprite as Sprite2D
@onready var player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
@onready var hitBox = $enemyHitbox as Area2D

@export var speed = 20.0
@export var hp = 10

func _process(delta):
	velocity = speed * global_position.direction_to(player.global_position)
	if (velocity.x < 0 and sprite.flip_h == false):
		sprite.flip_h = true
		hitBox.position.x *= -1
	elif (velocity.x > 0 and sprite.flip_h == true):
		sprite.flip_h = false
		hitBox.position.x *= -1
	move_and_collide(velocity * delta)

func _on_enemy_hurtbox_hurt(damage):
	hp -= damage
	Log.print("enemy hp: " + str(hp))
	if hp <= 0:
		queue_free()
		Log.print("SwordEnemy died")
