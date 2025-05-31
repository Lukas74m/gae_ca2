extends Node
class_name EnemyManager

@export var enemy_configs: Array[EnemyResource]

func spawn_enemy(resource: EnemyResource, position: Vector2):
	var enemy = resource.scene.instantiate()
	enemy.config = resource
	enemy.global_position = position
	add_child(enemy)
	return enemy
