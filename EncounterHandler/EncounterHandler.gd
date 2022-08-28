extends Node


const EncounterDataFilepath = "res://EncounterHandler/CurrentEncounter.json"
const EmptyEncounterFilepath = "res://EncounterHandler/EmptyEncounter.json"

var PlayerDataHandler = ""
var playerdata = {}
var encounterdata = {}
var rng = RandomNumberGenerator.new()

var enemies = {
    "lg_asteroid": {
        "name": "lg_asteroids",
        "xp":2,
        "paperclips":100,
        "tier":1
        },
    "sm_asteroid": {
        "name": "sm_asteroids",
        "xp":1,
        "paperclips":50,
        "tier":1
        },
    "turret": {
        "name": "turrets",
        "xp":4,
        "paperclips":150,
        "tier":2
        },
    "kamikaze": {
        "name": "kamikazes",
        "xp":3,
        "paperclips":200,
        "tier":3
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


func save_encounter_data():
    var file = File.new()

    file.open(EncounterDataFilepath, File.WRITE)
    file.store_line(to_json(encounterdata))

    file.close()


func reset_encounter_data():
    var file = File.new()

    if not file.file_exists(EmptyEncounterFilepath):
        print("Error attempting to load Empty Encounter json, filepath not found [%s])" % EmptyEncounterFilepath)
        return

    file.open(EmptyEncounterFilepath, File.READ)

    var text = file.get_as_text()
    var data_parse = JSON.parse(text)

    if data_parse.error != OK:
        print("Error returned when attempting to parse Empty Encounter json file in encounter generation")
        return

    encounterdata = data_parse.result

    file.close()

    save_encounter_data()


func gen_encounter(level):
    var xp_budget = 0
    var xp_used = 0
    var enc_reward = 0
    var tier = 0
    var boss = encounterdata.encounter.boss # Maintains boss state

    reset_encounter_data()
    encounterdata.encounter.boss = boss

    rng.randomize()

    # Tier 1 encounters
    if level < 4:
        print("Tier 1 encounter")
        tier = 1
        xp_budget = rng.randi_range(5,10)

    # Tier 2 encounters
    elif level >= 4 and level < 9:
        print("Tier 2 encounter")
        tier = 2
        xp_budget = rng.randi_range(14,25)

    # Tier 3 encounters & post-game, scales to player level
    elif level >= 9:
        print("Tier 3 encounter")
        tier = 3
        xp_budget = rng.randi_range(2*level,4*level)

    var attempts = 0
    while xp_used < xp_budget and attempts < 500:
        attempts += 1

        var new_enemy = get_random(enemies)

        if xp_used + new_enemy.xp <= xp_budget and new_enemy.tier <= tier:
            xp_used += new_enemy.xp
            enc_reward += new_enemy.paperclips
            enc_reward += new_enemy.paperclips
            encounterdata.encounter[new_enemy.name] += 1


    encounterdata.encounter.reward_money = enc_reward
    encounterdata.encounter.reward_xp = xp_used

    save_encounter_data()


func get_random(dict):
    var a = dict.keys()
    a = a[randi() % a.size()]
    return dict[a]


func _on_BossButton_pressed():
    encounterdata.encounter.boss = true
    print("bossbuttontest",encounterdata.encounter.boss)
    save_encounter_data()
    get_tree().change_scene("res://Battle/BattleSpace/BattleSpace.tscn")

func _on_EncounterButton_pressed():
    print("Encounter button pressed")
    reset_encounter_data()
    gen_encounter(playerdata.level)
    get_tree().change_scene("res://Battle/BattleSpace/BattleSpace.tscn")
