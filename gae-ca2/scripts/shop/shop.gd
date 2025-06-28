extends CanvasLayer

@onready var btn_option1: TextureButton = $Panel/HBoxContainer/Option1Button
@onready var btn_option2: TextureButton = $Panel/HBoxContainer/Option2Button
@onready var btn_option3: TextureButton = $Panel/HBoxContainer/Option3Button
@onready var panel: Panel = $Panel
@onready var label1: Label = $Panel/HBoxContainer/Option1Button/Label
@onready var label2: Label = $Panel/HBoxContainer/Option2Button/Label
@onready var label3: Label = $Panel/HBoxContainer/Option3Button/Label

var possible_upgrades = [
	{"stat": "attack_damage", "amount": 15, "label": "+15 Angriffsschaden"},
	{"stat": "max_health", "amount": 25, "label": "+25 Max. Leben"},
	{"stat": "crit_rate", "amount": 0.15, "label": "+15% Krit-Wahrscheinlichkeit"},
	{"stat": "crit_damage", "amount": 0.3, "label": "+30% Kritischer Schaden"}
]
var gamble_possible_upgrades = [
	{"stat": "attack_damage", "amount": 15, "label": "+ 0-15 Angriffsschaden"},
	{"stat": "max_health", "amount": 25, "label": " + 0-25 Max. Leben"}
]

# Upgrades that can be selected in the shop
var current_upgrades_in_shop = []  

func _ready():
	_close_shop()

func show_shop():
	current_upgrades_in_shop.clear()

	# Copy for shuffle and randomization 
	var upgrade_pool = possible_upgrades.duplicate()
	upgrade_pool.shuffle()
	var gamble_upgrade_pool = gamble_possible_upgrades.duplicate()
	gamble_upgrade_pool.shuffle()
	
	
	current_upgrades_in_shop.append(upgrade_pool[0])
	current_upgrades_in_shop.append(upgrade_pool[1])
	current_upgrades_in_shop.append(gamble_upgrade_pool[0])

	label1.text = current_upgrades_in_shop[0]["label"]
	label2.text = current_upgrades_in_shop[1]["label"]
	label3.text = current_upgrades_in_shop[2]["label"]

	panel.show()
	#get_tree().paused = true


func _on_option_1_button_pressed() -> void:
	_apply_upgrade(0)


func _on_option_2_button_pressed() -> void:
	_apply_upgrade(1)


func _apply_upgrade(index):
	if Global.player and index < current_upgrades_in_shop.size():
		var upgrade = current_upgrades_in_shop[index]
		Global.player.get_node("PlayerStats").base_stats[upgrade["stat"]] += upgrade["amount"]
		print(Global.player.get_node("PlayerStats").base_stats[upgrade["stat"]])
		_close_shop()
		
func _close_shop():
	panel.hide()
	get_tree().paused = false
