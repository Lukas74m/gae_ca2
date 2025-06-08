extends Node
class_name EnemyManager


@export var enemy_configs: Array[EnemyResource]
var enemy_base_scene = preload("res://scenes/enemies/EnemyBase.tscn")
var enemy_resources = []

func _ready():
	
	load_enemy_resources()


func load_enemy_resources():
	enemy_resources = {
		"slime": preload("res://resources/enemies/slime.tres")	
	}


func spawn_enemy(enemy):
	var enemy_object = enemy_base_scene.instantiate()
	enemy_object.enemy_resource = enemy_resources[enemy]
	enemy_object.global_position = Vector2(0, 0)
	enemy_object.add_to_group("enemies")
	add_child(enemy_object)	


func spawn_wave(enemy_composition, spawn_frequency):
	for enemy in enemy_composition:
		for enemy_amount in range(enemy_composition[enemy]):
			await get_tree().create_timer(spawn_frequency).timeout
			spawn_enemy(enemy)


func _on_enemy_died():
	print("Enemy died - could drop loot, add score, etc.")
	# Handle enemy death (drop items, play sound, add score)

func _on_enemy_attacked(target):
	print("Enemy attacked: ", target.name)
	# Apply damage to the target (usually the player)
	if target.has_method("take_damage"):
		# Get damage from the attacking enemy's config
		# You might need to pass the enemy reference instead of just target
		pass
