@abstract
extends Node2D

class_name Projectile

var hits_before_despawn : int = 1
var target_pos : Vector2
var speed : float = 1.0
var damage : int
var angle : Vector2
var turn_speed : float = 1.0 #TODO setup turnspeed

func move():
	pass
	#TODO setup movement
	#move_toward(position, pos, speed)
