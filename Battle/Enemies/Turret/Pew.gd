extends Node2D

var speed = 600
var edge_warp_thresh
func _physics_process(delta):
	position -= transform.y * speed * delta
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		position = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		position = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))

func _on_Lifespan_timeout():
	queue_free()

func _on_PewPew_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(1)
		queue_free()
	if body.is_in_group("enemy") and !body.is_in_group("turret"):
		body.take_dmg(40)
		queue_free()

func force_scale(_s):
	pass

func take_dmg(_x):
	pass
