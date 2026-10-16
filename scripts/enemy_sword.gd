extends CharacterBody2D

@onready var sprite = $sprite as Sprite2D
@onready var player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
@onready var hitBox = $enemyHitbox as Area2D

@export var speed = 20.0
@export var hp = 10

const HURT_FLASH_TIME = 0.1
const HURT_MATERIAL = preload("res://resources/hurt_canvasitem_material.tres")
var hurt_flash_timer := Timer.new()
var do_hurt_flash := false

func _process(delta):
	velocity = speed * global_position.direction_to(player.global_position)
	if (velocity.x < 0 and sprite.flip_h == false):
		sprite.flip_h = true
		hitBox.position.x *= -1
	elif (velocity.x > 0 and sprite.flip_h == true):
		sprite.flip_h = false
		hitBox.position.x *= -1
	move_and_collide(velocity * delta)
	
func _disable_hurt_flash():
	sprite.material = null
	do_hurt_flash = false

func _start_hurt_flash():
	#TODO hurt flash doesn't work
	do_hurt_flash = true
	sprite.material = HURT_MATERIAL
	hurt_flash_timer.start(HURT_FLASH_TIME)

func _on_enemy_hurtbox_hurt(damage):
	_start_hurt_flash()
	hp -= damage
	Log.print("enemy hp: " + str(hp))
	if hp <= 0:
		queue_free()
		Log.print("SwordEnemy died")

func _ready():
	#sprite_material = HURT_MATERIAL
	add_child(hurt_flash_timer)
	hurt_flash_timer.timeout.connect(_disable_hurt_flash)
