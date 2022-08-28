extends RigidBody2D
var pewpew = load("res://Battle/Player/PewPew.tscn")
var missile = load("res://Battle/Player/Missile.tscn")

var thrust = Vector2(0, -300)
var torque = 50000
var edge_warp_thresh = 0

var hp = 5
var shields = 3
var missiles = 100
var max_energy = 10
var energy = max_energy/3
var recharge_rate = 1

var unloading_energy = false
var invunerable = false

var pewpew_cost = 1

var has_pdl = true
var pdl_cost = .5
var pdl_level = 0
var pdl_activated = false
var pdl_targets = []


var has_missiles = false
var has_ioncannon = true
var cannon_rotation = 0
func _ready():
	$IonCannon.set_enabled(false)
	
	hp = PlayerDataHandler.PlayerData.ship.hp
	shields = PlayerDataHandler.PlayerData.ship.shield_max
	thrust = Vector2(0, -300 - PlayerDataHandler.PlayerData.ship.acceleration * 50)
	torque = 40000 + PlayerDataHandler.PlayerData.ship.handling * 250
	max_energy = PlayerDataHandler.PlayerData.ship.energy_max
	energy = max_energy/3
	missiles = PlayerDataHandler.PlayerData.ship.missiles
	
	pewpew_cost = 1 - PlayerDataHandler.PlayerData.ship.pewpews.energy_cost * .25
	
	pdl_cost = .5 - PlayerDataHandler.PlayerData.ship.point_defense.energy_cost/9
	$PDLTimer.wait_time = 0.35 - PlayerDataHandler.PlayerData.ship.point_defense.fire_rate / 10
	pdl_level = PlayerDataHandler.PlayerData.ship.point_defense.energy_regen
	
	has_pdl = PlayerDataHandler.PlayerData.ship.point_defense.enabled
	has_ioncannon = PlayerDataHandler.PlayerData.ship.ion_cannon.enabled
	has_missiles = PlayerDataHandler.PlayerData.ship.missile_launcher.enabled
	
	#read input from the battle zone
	if has_pdl:
		$Sprite/PointDefence.visible = true
	if has_missiles:
		$Sprite/MissileLauncher.visible = true
	if has_ioncannon:
		$Sprite/IonCannon.visible = true
	
	$IonCannon.scale.y = PlayerDataHandler.PlayerData.ship.ion_cannon.length * 1.5
	var sweep_range = PlayerDataHandler.PlayerData.ship.ion_cannon.sweep_range
	$CannonSweep.interpolate_property($IonCannon, "rotation", -PI/(5-sweep_range), PI/(5-sweep_range),1)
	$CannonSweep.playback_speed = 1 + (PlayerDataHandler.PlayerData.ship.ion_cannon.sweep_speed * 2)
	$CannonSweep.start()
		
func _process(_delta):
	update()

func _input(event):
	if event.is_action_pressed('debug_take_damage'):
		take_damage(1)
	if event.is_action_pressed('weapon1'):
		shoot_pewpew()
	if event.is_action_pressed('weapon2'):
		if has_pdl:
			toggle_pdl(true)
	if event.is_action_released('weapon2'):
		if has_pdl:
			toggle_pdl(false)
	if event.is_action_pressed('weapon3'):
		if energy > 5 and has_ioncannon:
			energy -= 5
			unloading_energy = true
			$IonCannon.set_enabled(true)
			$IonCannon.visible = true
			$Cannon.playing = true
	if event.is_action_pressed('weapon4'):
		shoot_missile()
		
func _physics_process(delta):
	if !pdl_activated and !unloading_energy and energy < max_energy:
		energy += recharge_rate * delta
	if pdl_activated and pdl_level > 0:
		energy += (recharge_rate * delta)/(4-pdl_level*.9)
	if unloading_energy:
		energy -= recharge_rate * delta * 2
		if energy <= 0:
			$IonCannon.set_enabled(false)
			unloading_energy = false
			$IonCannon.visible = false
			$Cannon.playing = false

func _integrate_forces(state):
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		state.transform.origin = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		state.transform.origin = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))
		
	if Input.is_action_pressed("ui_up"):
		applied_force = thrust.rotated(rotation)
		$Sprite/Thrusters.visible = true
		$Thruster.playing = true
	else:
		applied_force = Vector2()
		$Sprite/Thrusters.visible = false
		$Thruster.playing = false
	var rotation_dir = 0
	if Input.is_action_pressed("ui_right"):
		rotation_dir += 1
	if Input.is_action_pressed("ui_left"):
		rotation_dir -= 1
	applied_torque = rotation_dir * torque
	var rot = (linear_velocity.angle() - rotation) + PI/2

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
		$TakeDamage.play()
		
func die():
	print('lol im fuckin dead')
	queue_free()
	
func _draw():
	if pdl_activated:
		draw_circle(Vector2.ZERO,100,Color(1,0,1,.1))
	if pdl_activated and pdl_targets:
		for p in pdl_targets:
			draw_line(Vector2.ZERO, (p.position - position).rotated(-rotation), Color.aqua.darkened(.9))
		draw_line(Vector2.ZERO, (pdl_targets[0].position - position).rotated(-rotation), Color.purple)
#	for i in range(energy):
#		draw_line(Vector2((-i-1) * 3, 35).rotated(-rotation), Vector2((-i-1) * 3, 50).rotated(-rotation),Color.blue, 1, false)
#	if invunerable:
#		for i in range(shields):
#			draw_line(Vector2(i * 10, 35).rotated(-rotation), Vector2(i * 10, 42).rotated(-rotation),Color.gainsboro, 6, false)
#		for i in range(hp):
#			draw_line(Vector2(i * 5, 45).rotated(-rotation), Vector2(i * 5, 50).rotated(-rotation),Color.gainsboro, 3, false)
#	else:
#		for i in range(shields):
#			draw_line(Vector2(i * 10, 35).rotated(-rotation), Vector2(i * 10, 42).rotated(-rotation),Color.aqua, 6, false)
#		for i in range(hp):
#			draw_line(Vector2(i * 5, 45).rotated(-rotation), Vector2(i * 5, 50).rotated(-rotation),Color.green, 3, false)

func _on_InvincibilityTimer_timeout():
	invunerable = false
	$InvulFlash.stop()
	$Sprite.visible = true

func _on_InvulFlash_timeout():
	$Sprite.visible = not $Sprite.visible

func _on_PDLTimer_timeout():
	if !pdl_targets.empty():
		energy -= pdl_cost
		pdl_targets[0].take_damage(1)
		if energy <= 0:
			toggle_pdl(false)
		$PDLZap.play()

func _on_PDLZone_body_entered(body):
	if body.is_in_group('enemy'):
		pdl_targets.append(body)
	
func _on_PDLZone_body_exited(body):
	if body.is_in_group('enemy'):
		pdl_targets.remove(pdl_targets.find(body))
	
func _on_Player_body_entered(body):
	if body.is_in_group('enemy'):
		take_damage(1)
	if body.is_in_group('kboy'):
		body.queue_free()
		$KilledKamikaze.play()

func shoot_pewpew():
	if energy > 0:
		energy -= pewpew_cost
		var p = pewpew.instance()
		p.edge_warp_thresh = edge_warp_thresh
		p.position = $Muzzle.global_position
		p.rotation = rotation
		get_parent().add_child(p)

func shoot_missile():
	if missiles > 0:
		missiles -= 1
		var m = missile.instance()
		m.edge_warp_thresh = edge_warp_thresh
		m.position = global_position
		m.rotation = rotation
		get_parent().add_child(m)

func toggle_pdl(x):
	pdl_activated = x
	$PDLZone.visible = x
	$PDLHum.playing = x
	if x:
		$PDLTimer.start()
	else:
		$PDLTimer.stop()
