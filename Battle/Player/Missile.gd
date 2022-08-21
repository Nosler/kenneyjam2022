extends Area2D

var missile = load("res://Battle/Player/Missile.tscn")
var edge_warp_thresh
var speed = 1500
var state = 'arming'
var potential_targets = []
var target = null
var cluster = 0
var is_cluster = false

func _draw():
	if state == 'arming' and is_instance_valid(target):
		draw_line(Vector2.ZERO, (target.position - position).rotated(-rotation), Color.red.darkened(.5))
	if state == 'seeking':
		draw_line(Vector2.ZERO, (target.position - position).rotated(-rotation), Color.red)

func _ready():
	speed = 1000 + PlayerDataHandler.PlayerData.ship.missile_launcher.projectile_speed * 500
	if !is_cluster:
		cluster = PlayerDataHandler.PlayerData.ship.missile_launcher.cluster
		$ArmingTimer.wait_time = 1 - PlayerDataHandler.PlayerData.ship.missile_launcher.lockon_speed * .25
	else:
		$Deploy.volume_db = -20
		$LockOn.volume_db = -20
		$ArmingTimer.wait_time = 3

func _physics_process(delta):
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		position = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		position = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))
		
	match state:
		'arming':
			position += transform.y * 150 * delta
		'seeking':
			if is_instance_valid(target) and !target.is_dead:
				look_at(target.position)
				rotation = rotation + PI/2
				position -= transform.y * speed * delta
			else:
				state = 'drifting'
				$Thrusting.playing = false
				$Sprite/Trail.visible = false
		'drifting':
			position -= transform.y * 150 * delta
		'exploded':
			for b in $LockOnZone.get_overlapping_bodies():
				if b.is_in_group('enemy'):
					b.take_dmg(.5)
	update()

func _on_ArmingTimer_timeout():
	if state == 'arming':
		if target:
			state = 'seeking'
			$Thrusting.playing = true
			$Sprite/Trail.visible = true
			$SeekingTimer.start()
		else:
			state = 'drifting'

func _on_SeekingTimer_timeout():
	if state == 'seeking':
		state = 'drifting'
		$Sprite/Trail.visible = false

func _on_Missile_body_entered(body):
	if body.is_in_group('enemy') and state != 'arming':
		state = 'exploded'
		$Sprite.visible = false
		$ExplosionZone/Explosion.visible = true
		$ExplosionZone/Explosion.playing = true
		$ExplosionZone/ExplosionTimer.start()
		$ExplosionZone/AudioStreamPlayer2D.play()
		if cluster > 0 and !is_cluster:
			spawn_cluster()

func _on_ExplosionZone_body_entered(body):
	if state == 'exploded' and body.is_in_group('enemy'):
		body.take_dmg(3)
		
func _on_ExplosionTimer_timeout():
	queue_free()

func _on_LockOnZone_body_entered(body):
	if state == 'arming' and body.is_in_group('enemy'):
		potential_targets.append(body)
		var temp_target = target
		target = potential_targets[0]
		for t in potential_targets:
			if position.distance_to(t.position) < position.distance_to(target.position):
				target = t
		if temp_target != target:
			$LockOn.play()
		
func _on_LockOnZone_body_exited(body):
	if state == 'arming' and body.is_in_group('enemy'):
		potential_targets.remove(potential_targets.find(body))
		if !potential_targets.empty():
			target = potential_targets[0]
			for t in potential_targets:
				if position.distance_to(t.position) < position.distance_to(target.position):
					target = t
		else:
			target = null

func spawn_cluster():
	if !is_cluster:
		for i in range(cluster):
			print("SPAWNING GUY", cluster)
			var m = missile.instance()
			m.edge_warp_thresh = edge_warp_thresh
			m.position = global_position
			m.is_cluster = true
			m.rotation = rotation + (2*PI / (cluster - i))
			get_parent().add_child(m)
