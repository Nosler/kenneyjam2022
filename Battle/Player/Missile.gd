extends Area2D

var edge_warp_thresh
var speed = 1500
var state = 'arming'
var potential_targets = []
var target = null
var cluster = 0

func _draw():
	if state == 'arming' and !potential_targets.empty():
		draw_line(Vector2.ZERO, (potential_targets[0].position - position).rotated(-rotation), Color.red.darkened(.5))
	if state == 'seeking':
		draw_line(Vector2.ZERO, (target.position - position).rotated(-rotation), Color.red)

func _ready():
	speed = 1000 + PlayerDataHandler.PlayerData.ship.missile_launcher.projectile_speed * 500
	cluster = PlayerDataHandler.PlayerData.ship.missile_launcher.cluster
	$ArmingTimer.wait_time = 1 - PlayerDataHandler.PlayerData.ship.missile_launcher.lockon_speed * .25

func _physics_process(delta):
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		position = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		position = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))
		
	match state:
		'arming':
			position += transform.y * 150 * delta
		'seeking':
			if target:
				look_at(target.position)
				rotation = rotation + PI/2
				position -= transform.y * speed * delta
			else:
				state = 'drifting'
				$Sprite/Trail.visible = false
		'drifting':
			position -= transform.y * 150 * delta
		'exploded':
			pass
	update()

func _on_ArmingTimer_timeout():
	if state == 'arming':
		if !potential_targets.empty():
			target = potential_targets[0]
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
		$ExplosionZone/AudioStreamPlayer2D.play()
		
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
