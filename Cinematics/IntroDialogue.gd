extends CanvasLayer


var DialogueFilepath = "res://Cinematics/IntroDialogue.json"
var DialogueData = { }
var Display = ""
var Lines = [ ]
var CurrentLine = 0

var load_done = false


func _ready():
	Display = get_node("TextBoxContainer/MarginContainer/HBoxContainer/DisplayText")
	
	load_dialogue()
	
	for line in DialogueData.dialogue:
		Lines.insert(Lines.size(), line)
		
	Display.text = Lines[CurrentLine]
	
	print("Dialogue Handler Loaded")
	load_done = true


func load_dialogue():
	# Creating & opening json file with opening text
	var file = File.new()
	
	if not file.file_exists(DialogueFilepath):
		print("could not find DialogueFilepath")
		return

	file.open(DialogueFilepath, file.READ)

	# Reading the opened file and checking it for errors
	var text = file.get_as_text()
	var data_parse = JSON.parse(text)

	if data_parse.error != OK:
		print("json data parse returned error in load_dialogue function")
		return

	# Setting DialogueData for other functions & closing file
	DialogueData = data_parse.result
	
	file.close()


# Goes to the next dialogue when the player clicks
func _input(event: InputEvent) -> void:
	if not load_done:
		print("Not loaded")
		return

	Display = get_node("TextBoxContainer/MarginContainer/HBoxContainer/DisplayText")
	
	if event.is_action_pressed("click"):
		# If there are still more lines, displays the next line
		if CurrentLine < Lines.size()-1:
			CurrentLine += 1
			Display.text = Lines[CurrentLine]
			
		# If this is the last line, changes scenes to the HUB
		# When ready, this will send to the first encounter instead.
		elif CurrentLine >= Lines.size()-1:
			get_tree().change_scene("res://HUB/HUB.tscn")
