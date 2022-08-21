extends StaticBody2D

var target = null
var rng = RandomNumberGenerator.new()
var pew = load("res://Battle/Enemies/Turret/Pew.tscn")
var state = 'loading'
var rotate_speed = PI/69
var bullet_speed = 1000
var edge_warp_thresh
var hp = 45
var area_color = Color.blue

func _ready():
	area_color.a = .1
	$LoadingTimer.wait_time = 3

func _draw():
	draw_circle(Vector2.ZERO, $detection_area/CollisionShape2D.shape.radius, area_color)
func dot_prod(v1, v2):
	return v1.normalized().dot(v2.normalized())

func _physics_process(delta):
	match state:
		'loading':
			pass
		'aiming':
			# First, acquire a firing solution.
			var firing_soln = null
			for time_to_impact in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]:
				var close_point = target.global_position + target.get_linear_velocity() * (time_to_impact - 0.5)
				var far_point = target.global_position + target.get_linear_velocity() * time_to_impact
				var dist_to_close_point = (close_point - $Muzzle.global_position).length()
				var dist_to_far_point = (far_point - $Muzzle.global_position).length()
				var impact_close = dist_to_close_point / bullet_speed - (time_to_impact - 0.5)
				var impact_far = dist_to_far_point / bullet_speed - time_to_impact
				if impact_far < 0:
					# Firing soln possible
					var slope = (impact_close - impact_far) / 0.5
					var best_time = (time_to_impact - 0.5) + impact_close / slope
					firing_soln = target.global_position + target.get_linear_velocity() * best_time
					break

			if firing_soln:
				# Aim at the firing solution.
				var fire_dir = firing_soln - $Muzzle.global_position
				var angle = polar2cartesian(1.0, rotation)
				var difference = fire_dir.angle() - angle.angle()
				var dotprod = dot_prod(angle, fire_dir)
				if dotprod < -0.01:
					rotation -= rotate_speed
				elif dotprod > 0.01:
					rotation += rotate_speed
				else:
					print("BOOM")
					shoot_pew()
					$LoadingTimer.start()
					state = 'loading'
		'waiting':
			pass
	update()

func take_dmg(x):
	hp -= x
	$TakeDmg.play()
	if hp <= 0:
		queue_free()

func shoot_pew():
	var p = pew.instance()
	p.edge_warp_thresh = edge_warp_thresh
	p.position = $Muzzle.global_position
	p.rotation = rotation
	p.speed = bullet_speed
	$Shoot.play()
	get_parent().add_child(p)

func _on_LoadingTimer_timeout():
	if target:
		state = 'aiming'
		print("AIMING")
	else:
		state = 'waiting'

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		target = body
		if state == 'waiting':
			state = 'aiming'
			print("AIMING")

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		target = null
		if state == 'aiming':
			state = 'waiting'

func _on_Turret_body_entered(body):
	if body.name == "Player":
		print("BONK")

func force_scale(size):
	var s = range_lerp(size, 4500, 500, 1, .1)
	scale = Vector2(s,s)
