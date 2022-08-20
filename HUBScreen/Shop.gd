extends CanvasLayer


const PlayerDataFilepath = "res://Player/PlayerData.json"

var PlayerData = { }


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return
	#load_attributes()


# Reads PlayerData.json and turns it into PlayerData dict
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


# Writes the PlayerData.json file with PlayerData var
func save_attributes():
	var file = File.new()
	
	file.open(PlayerDataFilepath, File.WRITE)
	file.store_line(to_json(PlayerData))

	file.close()


func _on_ReturnButton_pressed() -> void:
	get_tree().change_scene("res://HUBScreen/HUB.tscn")
