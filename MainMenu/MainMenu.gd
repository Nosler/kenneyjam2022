extends CanvasLayer


func _ready():
	var startbutton = $Buttons/StartGame
	var credbutton = $Buttons/Credits
	var exitbutton = $Buttons/Exit
	
	startbutton.connect("pressed", self, "start_game")
	credbutton.connect("pressed", self, "run_credits")
	exitbutton.connect("pressed", self, "exit_game")
	
func start_game():
	print("Starting game.")
	get_tree().change_scene("res://IntroCinematic/IntroCinematic.tscn")
	
func run_credits():
	print("Running credits.")
	get_tree().change_scene("res://Credits/Credits.tscn")
	
func exit_game():
	print("Exiting game.")
	get_tree().quit()
