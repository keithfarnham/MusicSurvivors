@abstract
extends Node2D

class_name Projectile

var hits_before_despawn : int = 1
var target_pos : Vector2
var speed : float = 1.0
var damage : int
var angle : Vector2
var turn_speed : float = 1.0 #TODO setup turnspeed

func initialize(newDmg : int, newStartPos : Vector2, newTargetPos : Vector2, newSpeed : float, newAngle := Vector2.ZERO, newTurnSpeed := 1.0):
	damage = newDmg
	position = newStartPos
	target_pos = newTargetPos
	speed = newSpeed
	angle = newAngle
	turn_speed = newTurnSpeed
