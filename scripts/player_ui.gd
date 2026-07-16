extends CanvasLayer

class_name PlayerUI

@onready var healthbar = $GUIControl/HealthBar
@onready var xpbar = $GUIControl/XPBar

func update_hp_bar(newHP : int):
	healthbar.value = newHP
	
func update_xp_bar(newXP : int):
	xpbar.value = newXP

func debug_update_player_pos(newPos : Vector2):
	$GUIControl/DebugGUI/HBoxContainer/PosValue.text = "(%0.2f, %0.2f)" % [newPos.x, newPos.y]
