extends Node

const PlayerDataFilepath = "user://Player/PlayerData.json"
const PlayerDefaultDataFilepath = "res://Player/PlayerDefaultData.json"

var PlayerData = { }

# Runs load_attributes function on ready
func _ready():
	load_attributes()

# Reads PlayerData.json, parses it, then sets returned dict as PlayerData
func load_attributes():
	var file = File.new()

	if not file.file_exists(PlayerDataFilepath):
		print("Error attempting to load Player Data, filepath not found [%s])" % PlayerDataFilepath)
		return

	file.open(PlayerDataFilepath, File.READ)

	var text = file.get_as_text()
	var data_parse = JSON.parse(text)

	if data_parse.error != OK:
		print("Error returned when attempting to parse json file in PlayerData Handler")
		return

	PlayerData = data_parse.result

	file.close()
	

# Resets PlayerData var to match the PlayerDataDefault file's contents
func reset_attributes():
	var file = File.new()

	if not file.file_exists(PlayerDefaultDataFilepath):
		print("Error attempting to load Default Player Data, filepath not found [%s])" % PlayerDefaultDataFilepath)
		return

	file.open(PlayerDefaultDataFilepath, File.READ)

	var text = file.get_as_text()
	var data_parse = JSON.parse(text)

	if data_parse.error != OK:
		print("Error returned when attempting to parse json file in PlayerData Handler")
		return

	PlayerData = data_parse.result

	save_attributes()

	file.close()

# Writes the PlayerData.json file with PlayerData var
func save_attributes():
	var file = File.new()
	
	file.open(PlayerDataFilepath, File.WRITE)
	file.store_line(to_json(PlayerData))

	file.close()
