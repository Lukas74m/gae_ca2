extends "res://scripts/enemies/enemy_base.gd"

var enemy_scenes = {}
var enemy_resources  = {}
var spawn_amount = 2

func _ready():
	super._ready()
	load_enemy_scenes()
	load_enemy_resources() 

func load_enemy_scenes():
	enemy_scenes = {
		"Melee_Orc": preload("res://scenes/enemies/Melee_Orc.tscn"),
		#"Range_Orc": preload("res://scenes/enemies/Enemy_Range_Orc.tscn")
	}
	
# The entity names have to be the exact same like in the level.tres files
func load_enemy_resources():
	enemy_resources = {
		"Melee_Orc": preload("res://resources/enemies/melee_orc.tres"),
		#"Range_Orc": preload("res://resources/enemies/range_orc.tres"),
	}
	
	
# Overrides enemy_base.gd
func attack():
	#enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
	#enemy_animations.play("attack")
	attack_cooldown_timer = get_stat("attack_cooldown")
	#await enemy_animations.animation_finished
	for i in range(spawn_amount):
		# Kleine zufällige Abweichung um Überlagerung zu vermeiden
		var offset = Vector2(
			randf_range(-20, 20),  # Zufällig zwischen -20 und +20
			randf_range(-20, 20)
		)
		spawn_enemy_at("Melee_Orc", get_center_position() + offset)
	
	await get_tree().create_timer(0.3).timeout


func spawn_enemy_at(enemy_name, pos: Vector2):
	if enemy_name == null:
		printerr("Keine Enemy Scene zugewiesen!")
		return
	
	if enemy_name in enemy_scenes:
		var enemy = enemy_scenes[enemy_name].instantiate()
		enemy.is_spawned_by_other_entity = true
		enemy.enemy_resource = enemy_resources[enemy_name]
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = pos
	else:
		printerr("No such enemy ", enemy_name)
		print("Available keys: ", enemy_scenes.keys())


# Overrides enemy_base.gd
func _on_attack_frame_changed():
	
	# Fernkampfwaffe aufladen oder so
	# Kann man auch mit pass lassen
	
	#if enemy_animations.animation == "attack" and enemy_animations.frame == 10:
		#var distance = global_position.distance_to(Global.player.get_center_position())
		#if distance <= stats.get_stat("attack_range"):
			#Global.player.take_damage(get_stat("attack_damage"))
	pass 

# Overrides enemy_base.gd
func get_center_position():
	return center.global_position
	
func move_towards_player(delta: float, distance_to_player: float):
	# If in attack range and cooldown 0
	if distance_to_player <= get_stat("attack_range") and attack_cooldown_timer <= 0.0:
		change_state(EnemyState.ATTACK)
		return
	# Only move if not in attack range
	if distance_to_player > get_stat("attack_range") and attack_cooldown_timer <= 0.0:
		enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
		#enemy_animations.play("move")
		var direction = (Global.player.get_center_position() - global_position).normalized()
		velocity = direction * get_stat("movement_speed")
	else:
		# Stop moving when in attack range but cooldown >= 0
		enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
		#enemy_animations.play("idle")
		velocity = Vector2.ZERO
