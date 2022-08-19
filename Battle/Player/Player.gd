extends RigidBody2D

var thrust = Vector2(0, -300)
var torque = 50000
var edge_warp_thresh = 0

var hp = 5
var shields = 2

# From Godot Docs
func _integrate_forces(state):
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		state.transform.origin = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		state.transform.origin = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))
		
	if Input.is_action_pressed("ui_up"):
		applied_force = thrust.rotated(rotation)
	else:
		applied_force = Vector2()
	var rotation_dir = 0
	if Input.is_action_pressed("ui_right"):
		rotation_dir += 1
	if Input.is_action_pressed("ui_left"):
		rotation_dir -= 1
	applied_torque = rotation_dir * torque

func take_damage(dmg):
	if shields > 0:
		shields -= dmg
		$UI/HealthBar.size
	else:
		hp -= dmg
	if hp <= 0:
		die()
		
func die():
	print('lol im fuckin dead')
	queue_free()
