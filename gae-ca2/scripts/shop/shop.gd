extends CanvasLayer

@onready var btn_option1: TextureButton = $Panel/HBoxContainer/Option1Button
@onready var btn_option2: TextureButton = $Panel/HBoxContainer/Option2Button
@onready var panel: Panel = $Panel
@onready var label1: Label = $Panel/HBoxContainer/Option1Button/Label
@onready var label2: Label = $Panel/HBoxContainer/Option2Button/Label

var possible_upgrades = [
	{"stat": "attack_damage", "amount": 15, "label": "+15 Angriffsschaden"},
	{"stat": "max_health", "amount": 25, "label": "+25 Max. Leben"},
	{"stat": "crit_rate", "amount": 0.15, "label": "+15% Krit-Wahrscheinlichkeit"},
	{"stat": "crit_damage", "amount": 0.3, "label": "+30% Kritischer Schaden"}
]

var chosen_upgrades = []  

func _ready():
	_close_shop()

func show_shop():
	chosen_upgrades.clear()

	# Two differend upgrade-types
	var upgrade_pool = possible_upgrades.duplicate()
	upgrade_pool.shuffle()
	chosen_upgrades.append(upgrade_pool[0])
	chosen_upgrades.append(upgrade_pool[1])

	label1.text = chosen_upgrades[0]["label"]
	label2.text = chosen_upgrades[1]["label"]

	panel.show()
	#get_tree().paused = true


func _on_option_1_button_pressed() -> void:
	_apply_upgrade(0)


func _on_option_2_button_pressed() -> void:
	_apply_upgrade(1)


func _apply_upgrade(index):
	if Global.player and index < chosen_upgrades.size():
		var upgrade = chosen_upgrades[index]
		Global.player.get_node("PlayerStats").base_stats[upgrade["stat"]] += upgrade["amount"]
		print(Global.player.get_node("PlayerStats").base_stats[upgrade["stat"]])
		_close_shop()
		
func _close_shop():
	panel.hide()
	get_tree().paused = false
