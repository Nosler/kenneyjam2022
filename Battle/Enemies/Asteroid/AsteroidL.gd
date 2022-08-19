extends RigidBody2D

signal destroyed(position)

var edge_warp_thresh = 0
func _integrate_forces(state):
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		state.transform.origin = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		state.transform.origin = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))

func take_dmg():
	emit_signal('destroyed', position)
	queue_free()
