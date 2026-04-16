extends Node2D

signal picked_up

#TODO finish setup on weapon pickup
func _on_pickup_area_area_entered(area):
	if area.is_in_group("player"):
		picked_up.emit()
