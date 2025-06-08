extends Node2D

var current_level_kill_amount = 0
var progress_resources
var level_resource
var enemy_manager

var current_level_dict = {
	"current_level": 0,
	"level_wave_size": 0,
	"enemy_composition": {},
	"spawn_frequency": 0,
	"level_boss": ""
}

func _ready() -> void:
	enemy_manager = get_node("../EnemyManager")
	load_progress_resources()
	on_level_up()
	
	
func load_progress_resources():
	progress_resources = {
		"level_1": preload("res://resources/level/level_1.tres") 
	}


func on_level_up():
	var next_level = current_level_dict["current_level"] + 1
	var key = "level_" + str(next_level)
	
	if progress_resources.has(key):
		level_resource = progress_resources[key]
		load_level_information()
		enemy_manager.spawn_wave(
			current_level_dict["enemy_composition"],
			current_level_dict["spawn_frequency"]
		)
	else:
		printerr("No more levels!")


func load_level_information():
	current_level_dict["current_level"] = level_resource.current_level
	current_level_dict["level_wave_size"] = level_resource.level_wave_size
	current_level_dict["enemy_composition"] = level_resource.enemy_composition
	current_level_dict["spawn_frequency"] = level_resource.spawn_frequency
	current_level_dict["level_boss"] = level_resource.level_boss	


func update_level_progress():
	current_level_kill_amount += 1
	if current_level_kill_amount >= current_level_dict["level_wave_size"]:
		current_level_kill_amount = 0
		on_level_up()
