extends Node2D

var current_level_kill_amount = 0
var progress_resources
var level_resource
var enemy_manager

# Information about the current level
var current_level_dict = {
	"current_level": 0,
	"level_wave_size": 0,
	"enemy_composition": {},
	"spawn_frequency": 0,
	"boss_level": false,
	"level_boss_name": ""
}

# Gets the EnemyManager to send him the information
# Loads the information and starts the first level
func _ready() -> void:
	enemy_manager = get_node("../EnemyManager")
	await load_progress_resources()
	on_level_up()
	
# Loads all level resources with the specific information
func load_progress_resources():
	progress_resources = {
		"level_1": preload("res://resources/level/level_1.tres"),
		"level_2": preload("res://resources/level/level_2.tres"),
		"level_3": preload("res://resources/level/level_3.tres"),
		"level_4": preload("res://resources/level/level_4.tres")  
	}

# Gets the information from the new level
# Gives the information to the EnemyManager so that it can start spawning enemies
# Throws error if no more levels (game endend)
func on_level_up():
	var next_level = current_level_dict["current_level"] + 1
	var level_file_name = "level_" + str(next_level)
	
	if progress_resources.has(level_file_name):
		level_resource = progress_resources[level_file_name]
		load_level_information()
		# If no boss level spawn regular wave
		if current_level_dict["boss_level"] == false:
			enemy_manager.spawn_wave(
				current_level_dict["enemy_composition"],
				current_level_dict["spawn_frequency"]
			)
		# If boss level spawn boss
		else:
			enemy_manager.spawn_boss(current_level_dict["level_boss_name"])
	else:
		printerr("No more levels!")

# Saves the information about the new level localy
func load_level_information():
	current_level_dict["current_level"] = level_resource.current_level
	current_level_dict["level_wave_size"] = level_resource.level_wave_size
	current_level_dict["enemy_composition"] = level_resource.enemy_composition
	current_level_dict["spawn_frequency"] = level_resource.spawn_frequency
	current_level_dict["level_boss_name"] = level_resource.level_boss_name
	current_level_dict["boss_level"] = level_resource.boss_level

# Called when an enemy is killed
# Starts new level (later signal to game to load the shop)
func update_level_progress():
	current_level_kill_amount += 1
	# Checks if level is finished
	if current_level_kill_amount >= current_level_dict["level_wave_size"]:
		current_level_kill_amount = 0
		
		# Heal the player after each wave
		# Heal more before a boss wave
		if is_next_boss_level():
			Global.player.heal_player(0.5)
		else:
			Global.player.heal_player(0.25)
			
		await Global.shop.show_shop()
		on_level_up()

# Checks if the next lvel is a boss level
# Every forth level is a boss level
func is_next_boss_level():
	return (current_level_dict["current_level"] + 1) % 4 == 0

func get_level_wave_size():
	return current_level_dict["level_wave_size"]

func get_current_level_kill_amount():
	return current_level_kill_amount
	
func get_level():
	return current_level_dict["current_level"]
