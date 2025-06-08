extends Node2D

var current_wave_size
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
	#print("Should level up")
	var next_level = current_level_dict["current_level"] + 1
	level_resource = progress_resources["level_" + str(next_level)]
	load_level_information()
	enemy_manager.spawn_wave(current_level_dict["enemy_composition"], current_level_dict["spawn_frequency"])


func load_level_information():
	current_level_dict["current_level"] = level_resource.current_level
	current_level_dict["level_wave_size"] = level_resource.level_wave_size
	current_level_dict["enemy_composition"] = level_resource.enemy_composition
	current_level_dict["spawn_frequency"] = level_resource.spawn_frequency
	current_level_dict["level_boss"] = level_resource.level_boss	
