extends CanvasLayer

# Sets up PlayerDataHandler and connects buttons to their functions
func _ready():
    $Buttons/NewGame.connect("pressed", self, "new_game")
    $Buttons/LoadGame.connect("pressed", self, "start_game")
    $Buttons/Credits.connect("pressed", self, "run_credits")
    $Buttons/Exit.connect("pressed", self, "exit_game")
    var PlayerDataHandler = get_node("/root/PlayerDataHandler")
    PlayerDataHandler.reset_attributes()

func new_game():
    var PlayerDataHandler = get_node("/root/PlayerDataHandler")
    PlayerDataHandler.reset_attributes()
    start_game()

func start_game():
    var playerlevel = get_node("/root/PlayerDataHandler").PlayerData.ship.level

    # If PlayerData shows a level 1 player, sends them to the IntroCinematic. Otherwise sends them to the hub.
    if playerlevel > 1:
        get_tree().change_scene("res://HUB/HUB.tscn")

    else:
        get_tree().change_scene("res://Cinematics/IntroCinematic.tscn")

# Displays credits
func run_credits():
    get_tree().change_scene("res://Credits/Credits.tscn")

# Exits game
func exit_game():
    get_tree().quit()
