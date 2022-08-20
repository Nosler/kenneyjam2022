extends RigidBody2D

var edge_warp_thresh = 0
func _integrate_forces(state):
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		state.transform.origin = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		state.transform.origin = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))

func take_dmg(_n):
	queue_free()

func force_scale(size):
	$Sprite.scale.x = range_lerp(size, 90, 1000, 0, .5)
	$Sprite.scale.y = range_lerp(size, 90, 1000, 0, .5)
	$CollisionShape2D.shape.radius = (size / 100)
