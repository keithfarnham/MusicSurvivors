extends CanvasLayer

class_name PlayerUI

@onready var healthbar = $GUIControl/HealthBar
@onready var xpbar = $GUIControl/XPBar

func update_hp_bar(newHP : int):
	healthbar.value = newHP
	
func update_xp_bar(newXP : int):
	xpbar.value = newXP
