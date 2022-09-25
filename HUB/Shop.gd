extends CanvasLayer


const price_modifier = 1
const missile_price = 100

var PlayerDataHandler = ""
var data = ""

var pp_base_prices = [ 150, 150, 150 ]
var pd_base_prices = [ 150, 150, 150 ]
var ic_base_prices = [ 150, 150, 150 ]
var ml_base_prices = [ 150, 150, 150 ]

var pd_price = 500
var ic_price = 500
var ml_price = 500

var pp_actual_prices = pp_base_prices
var pd_actual_prices = pd_base_prices
var ic_actual_prices = ic_base_prices
var ml_actual_prices = ml_base_prices


func _ready():
    PlayerDataHandler = get_node("/root/PlayerDataHandler")
    data = PlayerDataHandler.PlayerData.ship

    set_pp() # Pew pews
    set_pd() # Point defense
    set_ic() # Ion cannon
    set_ml() # Missile launcher
    update_paperclips() # Paperclips

    $NameLabels/LabelContainer/PointDefenseLabel/BuyPD.text = "Point Defense: $%s" % pd_price
    $NameLabels/LabelContainer/IonCannonLabel/BuyIC.text = "Ion Cannon: $%s" % pd_price
    $NameLabels/LabelContainer/MissileLabel/BuyML.text = "Missile Launcher: $%s" % pd_price

# Does some math to update prices based on the initial upgrade cost and the cost_modifier constant
func get_prices(p1, p2, p3, ups1, ups2, ups3):
    var new_p1 = p1 * (price_modifier * (1 + ups1)) if ups1 < 3 else "-"
    var new_p2 = p2 * (price_modifier * (1 + ups2)) if ups2 < 3 else "-"
    var new_p3 = p3 * (price_modifier * (1 + ups3)) if ups3 < 3 else "-"

    return [ new_p1, new_p2, new_p3 ]


# UI Display Functions
# Sets the paperclips display
func update_paperclips():
    $Resources/VBoxContainer/Paperclips.text = "Paperclips:\n$%s" % data.paperclips

# Sets up the Pew Pew shop display
func set_pp():
    var pewpews = data.pewpews
    var enabled = pewpews.enabled

    $PewPewTrackers.visible = enabled
    $PewPewShop.visible = enabled

    update_paperclips()

    if enabled:
        var en_cost = pewpews.energy_cost
        var pr_range = pewpews.projectile_range
        var pr_speed = pewpews.projectile_speed

        $PewPewTrackers/PewPewLabels/PPUp1.text = "Energy Cost: %s/3" % en_cost
        $PewPewTrackers/PewPewLabels/PPUp2.text = "Range: %s/3" % pr_range
        $PewPewTrackers/PewPewLabels/PPUp3.text = "Laser Speed: %s/3" % pr_speed

        pp_actual_prices = get_prices(pp_base_prices[0], pp_base_prices[1], pp_base_prices[2], en_cost, pr_range, pr_speed)

        $PewPewShop/PewPewGrid/PP1Label.text = "$%s" % pp_actual_prices[0]
        $PewPewShop/PewPewGrid/PP2Label.text = "$%s" % pp_actual_prices[1]
        $PewPewShop/PewPewGrid/PP3Label.text = "$%s" % pp_actual_prices[2]

# Sets up the Point Defense shop display
func set_pd():
    var pd = data.point_defense
    var enabled = pd.enabled

    $PointDefenseTrackers.visible = enabled
    $PointDefenseShop.visible = enabled
    $NameLabels/LabelContainer/PointDefenseLabel/BuyPD.visible = not enabled

    update_paperclips()

    if enabled:
        var en_cost = pd.energy_cost
        var fr_rate = pd.fire_rate
        var en_reg = pd.energy_regen

        $PointDefenseTrackers/PointDefenseLabels/PDUp1.text = "Energy Cost: %s/3" % en_cost
        $PointDefenseTrackers/PointDefenseLabels/PDUp2.text = "Fire Rate: %s/3" % fr_rate
        $PointDefenseTrackers/PointDefenseLabels/PDUp3.text = "Energy Regen: %s/3" % en_reg

        pd_actual_prices = get_prices(pd_base_prices[0], pd_base_prices[1], pd_base_prices[2], en_cost, fr_rate, en_reg)

        $PointDefenseShop/PDGrid/PDLabel1.text = "$%s" % pd_actual_prices[0]
        $PointDefenseShop/PDGrid/PDLabel2.text = "$%s" % pd_actual_prices[1]
        $PointDefenseShop/PDGrid/PDLabel3.text = "$%s" % pd_actual_prices[2]

# Sets up the Ion Cannon shop display
func set_ic():
    var ic = data.ion_cannon
    var enabled = ic.enabled

    $IonCannonTrackers.visible = enabled
    $IonCannonShop.visible = enabled
    $NameLabels/LabelContainer/IonCannonLabel/BuyIC.visible = not enabled

    update_paperclips()

    if enabled:
        var bm_len = ic.length
        var sw_ran = ic.sweep_range
        var sw_spd = ic.sweep_speed

        $IonCannonTrackers/IonCannonLabels/ICUp1.text = "Beam Length: %s/3" % bm_len
        $IonCannonTrackers/IonCannonLabels/ICUp2.text = "Sweep Range: %s/3" % sw_ran
        $IonCannonTrackers/IonCannonLabels/ICUp3.text = "Sweeep Speed: %s/3" % sw_spd

        ic_actual_prices = get_prices(ic_base_prices[0], ic_base_prices[1], ic_base_prices[2], bm_len, sw_ran, sw_spd)

        $IonCannonShop/ICGrid/ICLabel1.text = "$%s" % ic_actual_prices[0]
        $IonCannonShop/ICGrid/ICLabel2.text = "$%s" % ic_actual_prices[1]
        $IonCannonShop/ICGrid/ICLabel3.text = "$%s" % ic_actual_prices[2]

# Sets up the Missile Launcher shop display
func set_ml():
    var ml = data.missile_launcher
    var enabled = ml.enabled

    $MissileTrackers.visible = enabled
    $MissileShop.visible = enabled
    $NameLabels/LabelContainer/MissileLabel/BuyML.visible = not enabled

    # Enables resource view & buy button
    $Resources/VBoxContainer/Missiles.visible = enabled
    $Resources/VBoxContainer/BuyMissileButton.visible = enabled

    update_paperclips()

    if enabled:
        var pr_spd = ml.projectile_speed
        var clust = ml.cluster
        var lckn_spd = ml.lockon_speed

        # Set here instead of through [label].visible to avoid UI alignment problems
        $NameLabels/LabelContainer/MissileLabel.text = "Missile Launcher"

        $MissileTrackers/MissileLabels/MLUp1.text = "Missile Speed: %s/3" % ml.projectile_speed
        $MissileTrackers/MissileLabels/MLUp2.text = "Cluster: %s/3" % ml.cluster
        $MissileTrackers/MissileLabels/MLUp3.text = "Lock-on Speed: %s/3" % ml.lockon_speed
        $Resources/VBoxContainer/BuyMissileButton.text = "Buy Missile: $%s" % missile_price
        $Resources/VBoxContainer/Missiles.text = "Missiles:\n%s" % data.missiles

        ml_actual_prices = get_prices(ml_base_prices[0], ml_base_prices[1], ml_base_prices[2], pr_spd, clust, lckn_spd)

        $MissileShop/MissGrid/MissLabel1.text = "$%s" % ml_actual_prices[0]
        $MissileShop/MissGrid/MissLabel2.text = "$%s" % ml_actual_prices[1]
        $MissileShop/MissGrid/MissLabel3.text = "$%s" % ml_actual_prices[2]


# Return to main screen button
func _on_ReturnButton_pressed() -> void:
    PlayerDataHandler.save_attributes()
    get_tree().change_scene("res://HUB/HUB.tscn")


# Pew Pew Shop Buttons
# Energy cost
func _on_PP1Button_pressed() -> void:
    # Checks the price, setting price to INF if all 3 upgrades have been bought
    # Checks upgrades through variable type for pp_actual_prices[0] which should be a string, not a float, if all 3 have been purchased
    # Same logic applies for every other shop button
    var price = pp_actual_prices[0] if int(typeof(pp_actual_prices[0])) == 3 else INF

    # If Player has enough paperclips, subtracts price, increments the upgrade tracker by 1, then re-checks Pew Pew shop display.
    # Same logic applies to every other shop button
    if data.paperclips >= price:
        data.paperclips -= price
        data.pewpews.energy_cost += 1
        set_pp()

# Projectile range
func _on_PP2Button_pressed() -> void:
    var price = pp_actual_prices[1] if int(typeof(pp_actual_prices[1])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.pewpews.projectile_range += 1
        set_pp()

# Projectile speed
func _on_PP3Button_pressed() -> void:
    var price = pp_actual_prices[2] if int(typeof(pp_actual_prices[2])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.pewpews.projectile_speed += 1
        set_pp()

# Point Defense Shop Buttons
# Energy cost
func _on_PDButton1_pressed() -> void:
    var price = pd_actual_prices[0] if int(typeof(pd_actual_prices[0])) == 3 else INF
    if data.paperclips >= price and data.point_defense.energy_cost < 3:
        data.paperclips -= price
        data.point_defense.energy_cost += 1
        set_pd()

# Fire rate
func _on_PDButton2_pressed() -> void:
    var price = pd_actual_prices[1] if int(typeof(pd_actual_prices[1])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.point_defense.fire_rate += 1
        set_pd()

# Energy regen
func _on_PDButton3_pressed() -> void:
    var price = pd_actual_prices[2] if int(typeof(pd_actual_prices[2])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.point_defense.energy_regen += 1
        set_pd()

# Ion Cannon Shop Buttons
# Beam length
func _on_ICButton1_pressed() -> void:
    var price = ic_actual_prices[0] if int(typeof(ic_actual_prices[0])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.ion_cannon.length += 1
        set_ic()

# Sweep range
func _on_ICButton2_pressed() -> void:
    var price = ic_actual_prices[1] if int(typeof(ic_actual_prices[1])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.ion_cannon.sweep_range += 1
        set_ic()

# Sweep speed
func _on_ICButton3_pressed() -> void:
    var price = ic_actual_prices[2] if int(typeof(ic_actual_prices[2])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.ion_cannon.sweep_speed += 1
        set_ic()

# Missile Launcher Shop Buttons
# Projectile speed
func _on_MissButton1_pressed() -> void:
    var price = ml_actual_prices[0] if int(typeof(ml_actual_prices[0])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.missile_launcher.projectile_speed += 1
        set_ml()

# Cluster
func _on_MissButton2_pressed() -> void:
    var price = ml_actual_prices[1] if int(typeof(ml_actual_prices[1])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.missile_launcher.cluster += 1
        set_ml()

# Lock-on Speed
func _on_MissButton3_pressed() -> void:
    var price = ml_actual_prices[2] if int(typeof(ml_actual_prices[2])) == 3 else INF
    if data.paperclips >= price:
        data.paperclips -= price
        data.missile_launcher.lockon_speed += 1
        set_ml()

# Buying missiles
func _on_BuyMissileButton_pressed() -> void:
    if data.paperclips >= missile_price:
        data.paperclips -= missile_price
        data.missiles += 1
        set_ml()

# Purchasing Weapon Types
func _on_BuyPD_pressed() -> void:
    if data.paperclips >= pd_price:
        data.paperclips -= pd_price
        data.point_defense.enabled = true
        $NameLabels/LabelContainer/PointDefenseLabel/BuyPD.visible = false
        set_pd()

func _on_BuyIC_pressed() -> void:
    if data.paperclips >= ic_price:
        data.paperclips -= ic_price
        data.ion_cannon.enabled = true
        $NameLabels/LabelContainer/IonCannonLabel/BuyIC.visible = false
        set_ic()

func _on_BuyML_pressed() -> void:
    if data.paperclips >= ml_price:
        data.paperclips -= ml_price
        data.missile_launcher.enabled = true
        $NameLabels/LabelContainer/MissileLabel/BuyML.visible = false
        set_ml()
