extends Node
class_name EnemyManager

@export var base_enemy_scene: PackedScene
@export var enemy_configs: Array[EnemyResource]

func spawn_enemy(resource: EnemyResource, position: Vector2):
	var enemy = resource.scene.instantiate()
	enemy.config = resource
	enemy.global_position = position
	
		# CONNECT ENEMY SIGNALS HERE
	enemy.died.connect(_on_enemy_died)
	enemy.attacked.connect(_on_enemy_attacked)
	
	add_child(enemy)
	return enemy

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
