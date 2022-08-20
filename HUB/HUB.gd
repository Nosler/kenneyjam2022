extends MarginContainer

const XpRate = 1.2 # Default 1.2

var PlayerDataHandler = ""
var data = ""
var xp_to_level = 0

var hp_on_levelup = 3
var shield_on_levelup = 1
var energy_on_levelup = 1
var accel_on_levelup = 1
var handle_on_levelup = 1

func _ready():
	PlayerDataHandler = get_node("/root/PlayerDataHandler")
	data = PlayerDataHandler.PlayerData.ship
	
	# Sets button visibility based on check_ready_level_up function's output
	buttons_visible(check_ready_level_up())
	
	# Sets initial textbox data
	refresh_textboxes()


# Sets the GUI buttons's visibility to given input
func buttons_visible(toggle):
	var hp_button = $Display/HullPoints/HPButton
	var shield_button = $Display/ShieldPoints/ShieldButton
	var accel_button = $Display/Acceleration/AccelButton
	var handling_button = $Display/Handling/HandlingButton
	var battery_button = $Display/Battery/BatteryButton
	
	if toggle is bool:
		hp_button.visible = toggle
		shield_button.visible = toggle
		accel_button.visible = toggle
		handling_button.visible = toggle
		battery_button.visible = toggle


# Rewrites the text for each label updated attribute values
func refresh_textboxes():
	var LvlLabel = $Display/LevelLabel
	var ExpLabel = $Display/ExpLabel
	var HullLabel = $Display/HullPoints/HPLabel
	var ShieldLabel = $Display/ShieldPoints/ShieldLabel
	var AccelLabel = $Display/Acceleration/AccelLabel
	var HandleLabel = $Display/Handling/HandlingLabel
	var BattLabel = $Display/Battery/BatteryLabel

	# Don't remove spaces in strings!!
	LvlLabel.text = "  Level: %s" % data.level
	AccelLabel.text = "  Acceleration: %s" % data.acceleration
	HandleLabel.text = "  Handling: %s" % data.handling
	ExpLabel.text = "  Exp: %s/%s" % [data.exp, xp_to_level]
	HullLabel.text = "  Hull Points: %s/%s" % [data.hp, data.hp_max]
	ShieldLabel.text = "  Shield Points: %s/%s" % [data.shield, data.shield_max]
	BattLabel.text = "  Energy: %s/%s" % [data.energy, data.energy_max]


# Checks if the player has enough experience to gain the next level
func check_ready_level_up() -> bool:
	xp_to_level = round(2* ((1 - pow(XpRate, data.level)) / (1 - XpRate)))
	return data.exp >= xp_to_level


# Handles all the level-up functionality
func level_up():
	data.exp -= xp_to_level
	data.level += 1
	
	# Calls save_attributes function to save the changed data to PlayerData.json, re-loads the data, then redraws all relevant textboxes
	PlayerDataHandler.save_attributes()
	PlayerDataHandler.load_attributes()
	refresh_textboxes()
	
	# Sets button visibility based on check_ready_level_up function's output
	buttons_visible(check_ready_level_up())


# Level Up buttons' signal handling
func _on_HPButton_pressed() -> void:
	var data = PlayerDataHandler.PlayerData.ship
	data.hp_max += hp_on_levelup
	data.hp += hp_on_levelup
	level_up()


func _on_ShieldButton_pressed() -> void:
	data.shield_max += shield_on_levelup
	data.shield += shield_on_levelup
	level_up()


func _on_AccelButton_pressed() -> void:
	data.acceleration += accel_on_levelup
	level_up()


func _on_HandlingButton_pressed() -> void:
	data.handling += handle_on_levelup
	level_up()


func _on_BatteryButton_pressed() -> void:
	data.energy_max += energy_on_levelup
	data.energy += energy_on_levelup
	level_up()


func _on_ShopButton_pressed() -> void:
	get_tree().change_scene("res://HUB/Shop.tscn")
