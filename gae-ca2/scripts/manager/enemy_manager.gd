extends Node
class_name EnemyManager

@export var enemy_configs: Array[EnemyResource]

var enemy_resources = []
var enemy_scenes = []
var boss_scenes = []

var increase_amount = 0.0

func _ready():
	load_enemy_scenes()
	load_enemy_resources()



func load_enemy_scenes():
	enemy_scenes = {
		"Melee_Orc": preload("res://scenes/enemies/Melee_Orc.tscn"),
		"Range_Orc": preload("res://scenes/enemies/Range_Orc.tscn"),
		"Shaman_Orc": preload("res://scenes/enemies/Shaman_Orc.tscn"),
		"Orc_Boss": preload("res://scenes/enemies/bosses/BossBase.tscn")
	}

# The entity names have to be the exact same like in the level.tres files
func load_enemy_resources():
	enemy_resources = {
		"Melee_Orc": preload("res://resources/enemies/melee_orc.tres"),
		"Range_Orc": preload("res://resources/enemies/range_orc.tres"),
		"Shaman_Orc": preload("res://resources/enemies/shaman_orc.tres"),
		"Orc_Boss": preload("res://resources/enemies/boss.tres")	
	}


func spawn_enemy(enemy_name: String):
	var enemy_object = enemy_scenes[enemy_name].instantiate()
	enemy_object.enemy_resource = enemy_resources[enemy_name]
	spawn_around_player(enemy_object)
	add_child(enemy_object)
	Global.enemies_alive += 1
	enemy_object.increase_stats(get_increase_amount())
	
	
func spawn_boss(boss_name: String, chapter: int):
	var boss_object = enemy_scenes[boss_name].instantiate()
	boss_object.enemy_resource = enemy_resources[boss_name]
	spawn_around_player(boss_object)
	add_child(boss_object)
	# Start timer for entourage spawning
	boss_object.entourage_timer.start()
	match chapter:
		# ----------------
		# Only for testing
		#1:
			#boss_object.dash_abilty_enabled = true
			#boss_object.range_ability_enabled = true
			#boss_object.boss_animations.hide()
			#boss_object.boss_with_orc_animations.show()
		# ----------------
		2: 
			boss_object.range_ability_enabled = true
			boss_object.boss_with_orc_animations.show()
			boss_object.boss_animations.hide()
		3: 
			boss_object.dash_abilty_enabled = true
			boss_object.range_ability_enabled = true
			boss_object.boss_with_orc_animations.show()
			boss_object.boss_animations.hide()
		_: pass


func spawn_wave(enemy_composition, spawn_frequency):
	for enemy in enemy_composition:
		for enemy_amount in range(enemy_composition[enemy]):
			# Limits max spawn amount of enemies at a time
			while Global.enemies_alive >= 10:
				await get_tree().create_timer(0.1).timeout
			
			await get_tree().create_timer(spawn_frequency).timeout
			spawn_enemy(enemy)
			
func get_increase_amount():
	return increase_amount

# Percentage by which enemies are buffed after each boss fight
func update_increase_amount():
	increase_amount += 0.3

# Enemies spawn around player
func spawn_around_player(enemy_object):
	var max_tries = 10
	var spawn_pos: Vector2

	for i in range(max_tries):
		var offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		spawn_pos = Global.player.get_center_position() + offset
		if is_inside_map(spawn_pos):
			break

	# Fallback auf Map-Mitte, falls 10 Versuche fehlschlagen
	if not is_inside_map(spawn_pos):
		spawn_pos = Vector2(0,0)
	enemy_object.global_position = spawn_pos


func is_inside_map(position: Vector2) -> bool:
	var shape = Global.map_area.get_node("CollisionShape2D")
	var rect_shape = shape.shape as RectangleShape2D
	if rect_shape:
		var shape_pos = shape.global_position
		var extents = rect_shape.extents
		var minimum = shape_pos - extents
		var maximum = shape_pos + extents
		return (
			position.x >= minimum.x and position.x <= maximum.x and
			position.y >= minimum.y and position.y <= maximum.y
		)
	return false
