extends CanvasLayer


var DialogueFilepath: = "res://IntroCinematic/IntroDialogue.json"
var DialogueData: = { }
var Display: = ""
var Lines: = [ ]
var CurrentLine: = 0


func _ready():
	var Display = get_node("TextBoxContainer/MarginContainer/HBoxContainer/DisplayText")
	
	load_dialogue()
	
	for line in DialogueData.dialogue:
		Lines.insert(Lines.size(), line)
		
	Display.text = Lines[CurrentLine]
	

func load_dialogue():
	
	# Creating & opening json file with opening text
	var file = File.new()
	
	if not file.file_exists(DialogueFilepath):
		return

	file.open(DialogueFilepath, file.READ)

	# Reading the opened file and checking it for errors
	var text = file.get_as_text()
	var data_parse = JSON.parse(text)

	if data_parse.error != OK:
		return

	# Setting DialogueData for other functions & closing file
	DialogueData = data_parse.result
	
	file.close()


# Goes to the next dialogue when the player clicks
func _input(event: InputEvent) -> void:
	var Display = get_node("TextBoxContainer/MarginContainer/HBoxContainer/DisplayText")
	
	if event.is_action_pressed("click"):
		if CurrentLine < Lines.size()-1:
			CurrentLine += 1
			Display.text = Lines[CurrentLine]
			
		else:
			return
