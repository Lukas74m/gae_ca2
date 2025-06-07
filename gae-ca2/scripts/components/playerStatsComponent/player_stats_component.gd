class_name PlayerStatComponent
extends Node

# base stats from the player
var base_stats = {
	"attack_damage": 20,
	"attack_range": 10,
	#"attack_cooldown": 2, 				# Cooldown is based on animations
	"dash_speed": 200,
	"movement_speed": 100,
	"max_health": 100
}

# additive modifiers from the player
var additive_mods = {
	"attack_damage": 0,
	"attack_range": 0,
	#"attack_cooldown": 0, 				# Cooldown is based on animations
	"dash_speed": 0,
	"movement_speed": 0,
	"max_health": 0
}

# multiplicative modifiers from the player
var multiplicative_mods = {
	"attack_damage": 1,
	"movement_speed": 1,
	"max_health": 1
}


# Returns the base damage with all upgrades 
func get_stat(stat_name: String):
	var base = base_stats.get(stat_name, 0)
	var add = additive_mods.get(stat_name, 0)
	var mult = multiplicative_mods.get(stat_name, 1)
	
	return (base + add) * mult


# Updates the specific additive modifiers 
func apply_add_modifier(stat_name: String, value: float):
	additive_mods[stat_name] = additive_mods.get(stat_name, 0) + value


# Updates the specific multiplicative modifiers 
func apply_mult_modifier(stat_name: String, value: float):
	multiplicative_mods[stat_name] = multiplicative_mods.get(stat_name, 1.0) * value


# resets all the modifiers
func reset_modifiers():
	for key in additive_mods.keys():
		additive_mods[key] = 0
	for key in multiplicative_mods.keys():
		multiplicative_mods[key] = 1.0
