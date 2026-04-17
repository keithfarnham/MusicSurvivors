extends Node2D

# Generic class for all pickups (XP, Weapons, Powerups, etc.)

class_name Pickup

signal picked_up

#func _on_pickup_area_entered(area):
	#if area.is_in_group("player"):
		#picked_up.emit()
