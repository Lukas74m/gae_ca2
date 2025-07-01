extends CanvasLayer
@onready var shop: CanvasLayer = $"."

@onready var btn_option1: TextureButton = $Option1Button
@onready var btn_option2: TextureButton = $Option2Button
@onready var btn_option3: TextureButton = $Option3Button

@onready var animated_sprite_2d: AnimatedSprite2D = $Option1Button/AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $Option2Button/AnimatedSprite2D2
@onready var animated_sprite_2d_3: AnimatedSprite2D = $Option3Button/AnimatedSprite2D3


#@onready var panel: Panel = $Panel
#@onready var reward_with_box_for_buttons: Sprite2D = $RewardWithBoxForButtons
@onready var label1: Label = $Option1Button/Label
@onready var label2: Label = $Option2Button/Label
@onready var label3: Label = $Option3Button/Label


#@export var button_textures := {
#	"common": preload("res://assets/rewards/Reward_Button_Normal2.png"),
#	"rare": preload("res://assets/rewards/Reward_Button_Rare.png"),
#	"epic": preload("res://assets/rewards/Reward_Button_Epic.png"),
#	"legendary": preload("res://assets/rewards/Reward_Button_Legendary.png")
#}

@export var button_textures := {
	"common": preload("res://assets/rewards/Reward_Button_v.2.png"),
	"rare": preload("res://assets/rewards/Reward_Button_v.2.png"),
	"epic": preload("res://assets/rewards/Reward_Button_v.2.png"),
	"legendary": preload("res://assets/rewards/Reward_Button_v.2.png")
}


# Globale Wahrscheinlichkeiten für alle Stats
var global_rarity_chances = {
	"common": 50,
	"rare": 30,
	"epic": 15,
	"legendary": 5
}

# Basis-Upgrades mit Seltenheitsstufen
var upgrade_templates = [
	{
		"stat": "attack_damage",
		"label_base": "Angriffsschaden",
		"rarities": {
			"common": {"amount": 10},
			"rare": {"amount": 14},
			"epic": {"amount": 18},
			"legendary": {"amount": 21}
		}
	},
	{
		"stat": "max_health",
		"label_base": "Max. Leben",
		"rarities": {
			"common": {"amount": 10},
			"rare": {"amount": 14},
			"epic": {"amount": 18},
			"legendary": {"amount": 25}
		}
	},
	{
		"stat": "crit_rate",
		"label_base": "Krit-Wahrscheinlichkeit",
		"rarities": {
			"common": {"amount": 0.08},
			"rare": {"amount": 0.12},
			"epic": {"amount": 0.16},
			"legendary": {"amount": 0.20}
		}
	},
	{
		"stat": "crit_damage",
		"label_base": "Kritischer Schaden",
		"rarities": {
			"common": {"amount": 0.15},
			"rare": {"amount": 0.22},
			"epic": {"amount": 0.30},
			"legendary": {"amount": 0.40}
		}
	}
]

var gamble_possible_upgrades = [
	{"stat": "attack_damage", "amount": 15, "label": "+ 0-27 Angriffsschaden", "gamble": true},
	{"stat": "max_health", "amount": 25, "label": " + 0-27 Max. Leben", "gamble": true}
]

# Farben für die Seltenheiten
var rarity_colors = {
	"common": Color.WHITE,
	"rare": Color.CYAN,
	"epic": Color.MAGENTA,
	"legendary": Color.GOLD
}

# Upgrades that can be selected in the shop
var current_upgrades_in_shop = []

func _ready():
	close_shop()

func show_shop():
	current_upgrades_in_shop.clear()
	
	# Erstelle 2 normale Upgrades mit Seltenheiten
	var selected_templates = upgrade_templates.duplicate()
	selected_templates.shuffle()
	
	for i in range(2):
		var upgrade_with_rarity = generate_upgrade_with_rarity(selected_templates[i])
		current_upgrades_in_shop.append(upgrade_with_rarity)
	
	# Füge ein Gamble-Upgrade hinzu
	var gamble_upgrade_pool = gamble_possible_upgrades.duplicate()
	gamble_upgrade_pool.shuffle()
	current_upgrades_in_shop.append(gamble_upgrade_pool[0])
	
	# Update Labels mit Farben
	update_shop_labels()
	#reward_with_box_for_buttons.show()
	shop.show()
	get_tree().paused = true

func generate_upgrade_with_rarity(template):
	var rarity = get_random_rarity()
	var rarity_data = template["rarities"][rarity]
	
	var upgrade = {
		"stat": template["stat"],
		"amount": rarity_data["amount"],
		"rarity": rarity,
		"gamble": false
	}
	
	# Erstelle das Label basierend auf dem Stat-Typ
	match template["stat"]:
		"crit_rate", "crit_damage":
			upgrade["label"] = "+%d%% %s" % [rarity_data["amount"] * 100, template["label_base"]]
		_:
			upgrade["label"] = "+%s %s" % [str(rarity_data["amount"]), template["label_base"]]
	
	return upgrade

func get_random_rarity():
	var total_chance = 0
	for rarity in global_rarity_chances:
		total_chance += global_rarity_chances[rarity]
	
	var random_value = randi() % total_chance
	var current_chance = 0
	
	for rarity in global_rarity_chances:
		current_chance += global_rarity_chances[rarity]
		if random_value < current_chance:
			return rarity
	
	return "common" # Fallback

# Diese Funktion wird nicht mehr benötigt, da keine Präfixe verwendet werden
# func get_rarity_prefix(rarity):

func update_shop_labels():
	var labels = [label1, label2, label3]
	var buttons = [btn_option1, btn_option2, btn_option3]
	
	for i in range(current_upgrades_in_shop.size()):
		var upgrade = current_upgrades_in_shop[i]
		labels[i].text = upgrade["label"]
		
		# Setze Farbe basierend auf Seltenheit (nur für nicht-Gamble Upgrades)
		if not upgrade.get("gamble", false):
			var rarity = upgrade.get("rarity", "common")
			labels[i].modulate = rarity_colors.get(rarity, Color.WHITE)
			buttons[i].texture_normal = button_textures[rarity]
			buttons[i].texture_hover = button_textures[rarity]
			buttons[i].texture_pressed = button_textures[rarity]
		else:
			var rarity = upgrade.get("rarity", "common")
			labels[i].modulate = Color.WHITE
			buttons[i].texture_normal = button_textures[rarity]
			buttons[i].texture_hover = button_textures[rarity]
			buttons[i].texture_pressed = button_textures[rarity]

func _on_option_1_button_pressed() -> void:
	await animated_sprite_2d.animation_finished
	apply_upgrade(0)

func _on_option_2_button_pressed() -> void:
	await animated_sprite_2d_2.animation_finished
	apply_upgrade(1)

func _on_option_3_button_pressed() -> void:
	await animated_sprite_2d_3.animation_finished
	apply_upgrade(2)

func apply_upgrade(index):
	if Global.player and index < current_upgrades_in_shop.size():
		var upgrade = current_upgrades_in_shop[index]
		var final_amount = upgrade["amount"]
		
		# Prüfen ob es sich um ein Gamble-Upgrade handelt
		if upgrade.get("gamble", false):
			print("GAMBLE ERKANNT!")
			final_amount = get_weighted_random_value(upgrade["amount"])
		else:
			print("UPGRADE ANGEWENDET - Seltenheit: ", upgrade.get("rarity", "N/A"))
		
		Global.player.get_node("PlayerStats").base_stats[upgrade["stat"]] += final_amount
		print("Angewendet: ", final_amount, " auf ", upgrade["stat"])
		print("Neuer Wert: ", Global.player.get_node("PlayerStats").base_stats[upgrade["stat"]])
		close_shop()

# Separate Funktion für die gewichtete Zufallsberechnung
func get_weighted_random_value(max_value) -> int:
	print("Berechne gewichteten Wert für max_value: ", max_value)
	var mid_point = float(max_value) / 2.0
	var random_float = randf()
	var weighted_value: float
	
	if random_float < 0.65:  # 65% Chance für untere Hälfte
		weighted_value = random_float / 0.65 * mid_point
		print("Untere Hälfte: ", weighted_value)
	else:  # 35% Chance für obere Hälfte
		weighted_value = mid_point + ((random_float - 0.65) / 0.35) * mid_point
		print("Obere Hälfte: ", weighted_value)
	
	var result = int(round(weighted_value))
	print("Finaler Gamble-Wert: ", result)
	return result

func close_shop():
	#reward_with_box_for_buttons.hide()
	animated_sprite_2d.visible = false
	animated_sprite_2d_2.visible = false
	animated_sprite_2d_3.visible = false
	
	shop.hide()
	get_tree().paused = false


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
