extends Node


const EncounterDataFilepath = "res://EncounterHandler/CurrentEncounter.json"

var PlayerDataHandler = ""
var playerdata = ""
var encounterdata = {}
var rng = RandomNumberGenerator.new()

var enemies = { 
	"lg_asteroid": {
		"name": "lg_asteroids", 
		"xp":2
		},
	"sm_asteroid": {
		"name": "sm_asteroids", 
		"xp":1
		},
	"turret": {
		"name": "turrets", 
		"xp":2
		},
	"kamikaze": {
		"name": "kamikazes", 
		"xp":1
		}
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerDataHandler = get_node("/root/PlayerDataHandler")
	playerdata = PlayerDataHandler.PlayerData.ship
	load_encounter_data()
	
	
func load_encounter_data():
	var file = File.new()

	if not file.file_exists(EncounterDataFilepath):
		print("Error attempting to load Current Encounter json, filepath not found [%s])" % EncounterDataFilepath)
		return
		
	file.open(EncounterDataFilepath, File.READ)
		
	var text = file.get_as_text()
	var data_parse = JSON.parse(text)

	if data_parse.error != OK:
		print("Error returned when attempting to parse json file in encounter generation")
		return

	encounterdata = data_parse.result

	file.close()

# Writes encounter data to the json
func save_encounter_data():
	var file = File.new()
	
	file.open(EncounterDataFilepath, File.WRITE)
	file.store_line(to_json(encounterdata))
	
	file.close()


func gen_encounter(level):
	var xp_budget = 0
	var xp_used = 0
	var enc_reward = 0
	
	rng.randomize()
	
	# Tier 1 encounters
	if level < 4:
		xp_budget = rng.randi_range(5,10)
		enc_reward = rng.randi_range(20,70)*10

	# Tier 2 encounters
	elif level in range(4,8):
		xp_budget = rng.randi_range(14,25)
		enc_reward = rng.randi_range(30,90)*10

	# Tier 3 encounters
	elif level in range (9,14):
		xp_budget = rng.randi_range(30,60)
		enc_reward = rng.randi_range(50,120)*10

	# Tier 4 encounters (post-game, scales encounter XP and rewards with level after this point
	elif level > 15:
		xp_budget = rng.randi_range(2*level,4*level)
		enc_reward = rng.randi_range(3*level, 6*level)*10

	var attempts = 0
	while xp_used < xp_budget and attempts < 500:
		attempts += 1

		var new_enemy = get_random(enemies)

		if xp_used + new_enemy.xp <= xp_budget:
			xp_used += new_enemy.xp
			encounterdata.encounter[new_enemy.name] += 1

	encounterdata.encounter.reward_money = enc_reward
	encounterdata.encounter.reward_xp = xp_used

	save_encounter_data()


func get_random(dict):
	var a = dict.keys()
	a = a[randi() % a.size()]
	return dict[a]


func _pressed():
	gen_encounter(playerdata.level)
