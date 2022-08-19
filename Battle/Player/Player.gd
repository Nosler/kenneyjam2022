extends RigidBody2D

var thrust = Vector2(0, -300)
var torque = 50000
var edge_warp_thresh = 0

var hp = 5
var shields = 2
var invunerable = false

func _process(_delta):
	update()

func _input(event):
	if event.is_action_pressed('debug_take_dmg'):
		take_damage(1)
		
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
	if !invunerable:
		if shields > 0:
			shields -= dmg
		else:
			hp -= dmg
		if hp <= 0:
			die()
		invunerable = true
		$InvulTimer.start()
		$InvulFlash.start()
		
func die():
	print('lol im fuckin dead')
	queue_free()

func _draw():
	if invunerable:
		for i in range(shields):
			draw_line(Vector2(i * 5, 35).rotated(-rotation), Vector2(i * 5, 40).rotated(-rotation),Color.gainsboro, 2, false)
		for i in range(hp):
			draw_line(Vector2(i * 5, 45).rotated(-rotation), Vector2(i * 5, 50).rotated(-rotation),Color.gainsboro, 2, false)
	else:
		for i in range(shields):
			draw_line(Vector2(i * 5, 35).rotated(-rotation), Vector2(i * 5, 40).rotated(-rotation),Color.aqua, 2, false)
		for i in range(hp):
			draw_line(Vector2(i * 5, 45).rotated(-rotation), Vector2(i * 5, 50).rotated(-rotation),Color.green, 2, false)

func _on_InvincibilityTimer_timeout():
	invunerable = false
	$InvulFlash.stop()
	$Sprite.visible = true

func _on_InvulFlash_timeout():
	$Sprite.visible = not $Sprite.visible

func _on_Player_body_entered(body):
	if body.is_in_group('enemy'):
		take_damage(1)

