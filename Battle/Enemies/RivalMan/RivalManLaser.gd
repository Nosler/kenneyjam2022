extends Node2D

var speed = 500
var edge_warp_thresh

func _physics_process(delta):
	position -= transform.y * speed * delta
	
func force_scale(_x):
	print('lol, lmao')

func take_damage(_n):
	queue_free()

func _on_Lifespan_timeout():
	queue_free()

func _on_RivalManLaser_body_entered(body):
	if body.is_in_group("player") or (body.is_in_group("enemy") and !body.is_in_group("boss")):
		body.take_damage(1)
		queue_free()
