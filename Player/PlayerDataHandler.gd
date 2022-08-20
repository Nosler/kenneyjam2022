extends Node

const PlayerDataFilepath = "res://Player/PlayerData.json"

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
		print("Error returned when attempting to parse json file in load_attributes")
		return

	PlayerData = data_parse.result

	file.close()


# Writes the PlayerData.json file with PlayerData dict-turned-json
func save_attributes():
	var file = File.new()
	
	file.open(PlayerDataFilepath, File.WRITE)
	file.store_line(to_json(PlayerData))

	file.close()
