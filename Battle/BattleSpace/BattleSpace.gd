extends Node2D

var rivalman = load("res://Battle/Enemies/RivalMan/RivalMan.tscn")
var asteroidS = load("res://Battle/Enemies/Asteroid/AsteroidS.tscn")
var asteroidL = load("res://Battle/Enemies/Asteroid/AsteroidL.tscn")
var size = 2300
var col = Color.red
var cspot_offset = 1
var lost = false
var is_boss_level = false

func _input(event):
	if event.is_action_pressed("debug_spawn_asteroid"):
		spawn_large_asteroid()
	if event.is_action_pressed('debug_sizeup'):
		size = clamp(size + 100, 100, 10000)
		update()
		$CSpotNW.position = Vector2((-size/2)*cspot_offset,(-size/2)*cspot_offset)
		$CSpotNE.position = Vector2((size/2)*cspot_offset,(-size/2)*cspot_offset)
		$CSpotSW.position = Vector2((-size/2)*cspot_offset,(size/2)*cspot_offset)
		$CSpotSE.position = Vector2((size/2)*cspot_offset,(size/2)*cspot_offset)
		print(size)
		for child in get_children():
			if child.is_in_group('enemy') or child.is_in_group('player'):
				if child.is_in_group('enemy'):
					child.force_scale(size)
				child.edge_warp_thresh = size/2
			
	if event.is_action_pressed('debug_sizedown'):
		size = clamp(size - 100, 100, 10000)
		update()
		$CSpotNW.position = Vector2((-size/2)*cspot_offset,(-size/2)*cspot_offset)
		$CSpotNE.position = Vector2((size/2)*cspot_offset,(-size/2)*cspot_offset)
		$CSpotSW.position = Vector2((-size/2)*cspot_offset,(size/2)*cspot_offset)
		$CSpotSE.position = Vector2((size/2)*cspot_offset,(size/2)*cspot_offset)
		for child in get_children():
			print(size)
			if child.is_in_group('enemy') or child.is_in_group('player'):
				if child.is_in_group('enemy'):
					child.force_scale(size)
				child.edge_warp_thresh = size/2

func _ready():
	PlayerDataHandler.load_attributes()
	print("Player Level %s" % PlayerDataHandler.PlayerData.ship.level)
	var player_durability = clamp(PlayerDataHandler.PlayerData.ship.hp * 1.3 + PlayerDataHandler.PlayerData.ship.shield * 3, 5, 65)
	size = -65 * player_durability + 4500
	var cam_margin = range_lerp(size, 4500, 500, 300, 40)
	$Player.edge_warp_thresh = size/2
	$CanvasLayer/UI/Energy.rect_size.x = 50
	$CanvasLayer/UI/Defence/HP.rect_size.x = 50
	$CanvasLayer/UI/Defence/Shield.rect_size.x = 50
	$Camera2D.margin = Vector2(cam_margin,cam_margin)
	$CSpotNW.position = Vector2((-size/2)*cspot_offset,(-size/2)*cspot_offset)
	$CSpotNE.position = Vector2((size/2)*cspot_offset,(-size/2)*cspot_offset)
	$CSpotSW.position = Vector2((-size/2)*cspot_offset,(size/2)*cspot_offset)
	$CSpotSE.position = Vector2((size/2)*cspot_offset,(size/2)*cspot_offset)
	$Camera2D.add_target($Player)
	$Camera2D.add_target($CSpotNW)
	$Camera2D.add_target($CSpotNE)
	$Camera2D.add_target($CSpotSW)
	$Camera2D.add_target($CSpotSE)
	EncounterHandler.gen_encounter(PlayerDataHandler.PlayerData.ship.level)
	is_boss_level = EncounterHandler.encounterdata.is_boss_level
	for i in range(EncounterHandler.encounterdata.encounter.lg_asteroids):
		spawn_large_asteroid()
	for i in range(EncounterHandler.encounterdata.encounter.sm_asteroids):
		spawn_smol_asteroid()
	for i in range(EncounterHandler.encounterdata.encounter.turrets):
		spawn_turret()
	for i in range(EncounterHandler.encounterdata.encounter.kamikazes):
		spawn_kamikaze()
	if is_boss_level:
		$CanvasLayer/BossHP.visible = true
		spawn_rivalman()


func _process(delta):
	if !lost:
		update()
		if $Player.pdl_activated:
			$CanvasLayer/UI/Energy.color = Color.indigo
		elif $Player.unloading_energy:
			$CanvasLayer/UI/Energy.color = Color.green.lightened(.4)
		elif ($Player.has_ioncannon and $Player.energy > 5):
			$CanvasLayer/UI/Energy.color = Color.green
		else:
			$CanvasLayer/UI/Energy.color = Color.blue
		$CanvasLayer/UI/Energy.rect_size.x = $Player.energy * 50
		$CanvasLayer/UI/Defence/HP.rect_size.x = $Player.hp * 30
		$CanvasLayer/UI/Defence/Shield.rect_size.x = $Player.shields * 50
	if is_boss_level and is_instance_valid($RivalMan):
		$CanvasLayer/BossHP.rect_size.x = $RivalMan.hp * 5
	
func _draw():
	draw_rect(Rect2(-size/2, -size/2, size, size), col, false, 1, false)
	draw_rect(Rect2(-size/2 - size/100, -size/2 - size/100, size + size/50, size + size/50), col.darkened(.5), false, 1, false)
	
func _on_Player_ready():
	$Player.edge_warp_thresh = size/2
	
func spawn_large_asteroid():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var a = asteroidL.instance()
	a.connect("destroyed", self, "on_large_asteroid_destroyed")
	a.angular_velocity = rand.randf_range(0,50)
	a.linear_velocity = Vector2(0, rand.randf_range(50, size/10)).rotated(rand.randf_range(0,360))
	a.edge_warp_thresh = size/2
	a.force_scale(size)
	a.position.y = rand.randf_range(-size/2, size/2)
	a.position.x = rand.randf_range(-size/2, size/2)
	add_child(a)

func spawn_smol_asteroid():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var a = asteroidS.instance()
	a.angular_velocity = rand.randf_range(0,50)
	a.linear_velocity = Vector2(0, rand.randf_range(50, size/10)).rotated(rand.randf_range(0,360))
	a.edge_warp_thresh = size/2
	a.force_scale(size)
	a.position.y = rand.randf_range(-size/2, size/2)
	a.position.x = rand.randf_range(-size/2, size/2)
	add_child(a)

func spawn_turret():
	pass

func spawn_kamikaze():
	pass

func spawn_rivalman():
	$Player.position = Vector2(0, size/3)
	var r = rivalman.instance()
	r.force_scale(size)
	r.position = Vector2.ZERO
	r.connect("destroyed", self, "win_game")
	add_child(r)

func on_large_asteroid_destroyed(p):
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	for i in range(3):
		var a = asteroidS.instance()
		a.angular_velocity = rand.randf_range(5,60)
		a.linear_velocity = Vector2(0, rand.randf_range(50, size/10)).rotated(rand.randf_range(0,360))
		a.edge_warp_thresh = size/2
		a.position = p
		a.force_scale(size)
		add_child(a)

func _on_CheckForEnemies_timeout():
	var children = get_children()
	var enemies = []
	for child in children:
		if child.is_in_group('enemy'):
			enemies.insert(enemies.size(), child)
			print("Found enemy")
			#return
	if enemies.size() > 0:
		print(enemies)
		return
	print("No enemies.")
	win()

func _on_Player_tree_exiting():
	if !lost:
		lose()
	
func win():
	PlayerDataHandler.PlayerData.ship.exp += EncounterHandler.encounterdata.encounter.reward_xp
	PlayerDataHandler.PlayerData.ship.paperclips += EncounterHandler.encounterdata.encounter.reward_money
	PlayerDataHandler.PlayerData.ship.hp = $Player.hp
	PlayerDataHandler.PlayerData.ship.missiles = $Player.missiles
	PlayerDataHandler.save_attributes()
	$CanvasLayer/YouWin.visible = true
	$CanvasLayer/YouWin/YouWinLabel.text = "YOU WERE VICTORIOUS!\n\nExperience Gained: %s\nPaperclips Earned: %s" % [EncounterHandler.encounterdata.encounter.reward_xp, EncounterHandler.encounterdata.encounter.reward_money]
	$WinTimer.start()
	get_tree().paused = true

func win_game():
	print("u win")
	
func lose():
	$Camera2D.remove_target($Player)
	lost = true
	$LoseTimer.start()
	$CanvasLayer/YouLose.visible = true
	
func _on_LoseTimer_timeout():
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
	
func _on_WinTimer_timeout():
	get_tree().change_scene("res://HUB/HUB.tscn")
