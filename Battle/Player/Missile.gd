extends Area2D

var edge_warp_thresh
var speed = 1500
var state = 'arming'
var potential_targets = []
var target = null
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		position = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		position = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))
		
	match state:
		'arming':
			position += transform.y * 150 * delta
		'seeking':
			look_at(target.position)
			rotation = rotation + PI/2
			position -= transform.y * speed * delta
		'drifting':
			position -= transform.y * 150 * delta
		'exploded':
			pass

func _on_ArmingTimer_timeout():
	if state == 'arming':
		if !potential_targets.empty():
			target = potential_targets[potential_targets.size()-1]
			state = 'seeking'
			$Sprite/Trail.visible = true
			$SeekingTimer.start()
		else:
			state = 'drifting'

func _on_SeekingTimer_timeout():
	if state == 'seeking':
		state = 'drifting'
		$Sprite/Trail.visible = false

func _on_Missile_body_entered(body):
	if body.is_in_group('enemy'):
		state = 'exploded'
		$Sprite.visible = false
		$ExplosionZone/Explosion.visible = true
		$ExplosionZone/Explosion.playing = true
		$ExplosionZone/ExplosionTimer.start()
		
func _on_ExplosionZone_body_entered(body):
	if state == 'exploded' and body.is_in_group('enemy'):
		body.take_dmg(3)
		
func _on_ExplosionTimer_timeout():
	queue_free()

func _on_LockOnZone_body_entered(body):
	if state == 'arming' and body.is_in_group('enemy'):
		potential_targets.append(body)

func _on_LockOnZone_body_exited(body):
	if state == 'arming' and body.is_in_group('enemy'):
		potential_targets.remove(potential_targets.find(body))
