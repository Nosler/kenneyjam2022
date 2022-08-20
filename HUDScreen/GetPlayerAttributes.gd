extends MarginContainer


var PlayerDataFilepath = "res://Player/PlayerData.json"
var PlayerData = { }
var XpRate = 1.2
var xp_to_level = 0

func _ready():
	
	# Handling loading the player's attributes
	load_attributes()
	
	# Sets initial textbox data
	xp_to_level = round(2* ((1 - pow(XpRate, PlayerData.ship.level)) / (1 - XpRate)))
	refresh_textboxes()

	# Checks if the player can level
	check_ready_level_up()


func load_attributes():
	var file = File.new()

	if not file.file_exists(PlayerDataFilepath):
		print("could not find PlayerDataFilepath")
		return

	file.open(PlayerDataFilepath, File.READ)

	var text = file.get_as_text()
	var data_parse = JSON.parse(text)

	if data_parse.error != OK:
		print("json data parse returned error in load_attributes function")
		return

	PlayerData = data_parse.result

	file.close()


func save_attributes():
	var file = File.new()
	
	file.open(PlayerDataFilepath, File.WRITE)
	file.store_line(to_json(PlayerData))

	file.close()


func buttons_visible(toggle):
	var hp_button = $Display/HullPoints/HPButton
	var shield_button = $Display/ShieldPoints/ShieldButton
	var accel_button = $Display/Acceleration/AccelButton
	var handling_button = $Display/Handling/HandlingButton
	var battery_button = $Display/Battery/BatteryButton
	
	hp_button.visible = toggle
	shield_button.visible = toggle
	accel_button.visible = toggle
	handling_button.visible = toggle
	battery_button.visible = toggle


func refresh_textboxes():
	var attributes = PlayerData.ship
	var LvlLabel = $Display/LevelLabel
	var ExpLabel = $Display/ExpLabel
	var HullLabel = $Display/HullPoints/HPLabel
	var ShieldLabel = $Display/ShieldPoints/ShieldLabel
	var AccelLabel = $Display/Acceleration/AccelLabel
	var HandleLabel = $Display/Handling/HandlingLabel

	LvlLabel.text = "Level: %s" % attributes.level
	ExpLabel.text = "Exp: %s/%s" % [attributes.exp, xp_to_level]
	HullLabel.text = "Hull Points: %s/%s" % [attributes.hp, attributes.hp_max]
	ShieldLabel.text = "Shield Points: %s/%s" % [attributes.shield, attributes.shield_max]
	AccelLabel.text = "Acceleration: %s" % attributes.acceleration
	HandleLabel.text = "Handling: %s" % attributes.handling


func check_ready_level_up():
	var xp = PlayerData.ship.exp
	xp_to_level = round(2* ((1 - pow(XpRate, PlayerData.ship.level)) / (1 - XpRate)))
	
	if xp >= xp_to_level:
		buttons_visible(true)

	else:
		buttons_visible(false)


func level_up():
	PlayerData.ship.exp -= xp_to_level
	PlayerData.ship.level += 1
	
	save_attributes()
	check_ready_level_up()
	refresh_textboxes()


func _on_HPButton_pressed() -> void:
	PlayerData.ship.hp_max += 1
	PlayerData.ship.hp += 1
	level_up()


func _on_ShieldButton_pressed() -> void:
	PlayerData.ship.shield_max += 1
	PlayerData.ship.shield += 1
	level_up()


func _on_AccelButton_pressed() -> void:
	PlayerData.ship.acceleration += 1
	level_up()


func _on_HandlingButton_pressed() -> void:
	PlayerData.ship.handling += 1
	level_up()


func _on_BatteryButton_pressed() -> void:
	PlayerData.ship.energy_max += 1
	PlayerData.ship.energy += 1
	level_up()
