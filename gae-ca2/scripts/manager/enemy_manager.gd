extends Node
class_name EnemyManager


@export var enemy_configs: Array[EnemyResource]
var enemy_base_scene = preload("res://scenes/enemies/EnemyBase.tscn")
var enemy_resources = []

func _ready():
	
	load_enemy_resources()


func load_enemy_resources():
	enemy_resources = [
		preload("res://resources/enemies/slime.tres")
	]
	#base_enemy_scenes.shuffle()

func spawn_enemy(position: Vector2):
	for enemy_resource in enemy_resources:
		var enemy_object = enemy_base_scene.instantiate()
		enemy_object.enemy_resource = enemy_resource
		enemy_object.global_position = position
		enemy_object.add_to_group("enemies")
		#enemy_object.died.connect(_on_enemy_died)
		#enemy_object.attacked.connect(_on_enemy_attacked)
	
		add_child(enemy_object)
		#return enemy
	

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
