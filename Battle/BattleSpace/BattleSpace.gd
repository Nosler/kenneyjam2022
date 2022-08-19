extends Node2D

var size = 300

func _draw():
	draw_rect(Rect2(-size/2, -size/2, size, size), Color.aqua, false, 1, false)
	
func _ready():
	pass # Replace with function body.

func _on_Player_ready():
	$Player.edge_warp_thresh = size/2
