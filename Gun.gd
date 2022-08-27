extends Node2D

var pewpew = load("res://Battle/Enemies/RivalMan/RivalManLaser.tscn")
export var is_fast_laser = false
var knocked_out = false

func shoot():
	if !knocked_out:
		var p = pewpew.instance()
		p.position = $Muzzle.global_position
		p.scale = global_scale
		if is_fast_laser:
			p.scale = global_scale / 2
			p.speed *= 2
		p.rotation = global_rotation
		get_parent().get_parent().add_child(p)
		$Pew.play()

func take_damage(_n):
	$DisableTimer.start()
	$Sprite.modulate = Color.red
	knocked_out = true
	
func _on_DisableTimer_timeout():
	$Sprite.modulate = Color.white
	knocked_out = false
