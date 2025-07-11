extends "res://scripts/enemies/enemy_base.gd"

@onready var summon_circle: Sprite2D = $SummonCircle

var enemy_scenes = {}
var enemy_resources  = {}
var spawn_amount = 2
var amount_enemies_spawned = 0
var MAX_SPAWN_AMOUNT = 2

func _ready():
	super._ready()
	load_enemy_scenes()
	load_enemy_resources() 
	summon_circle.visible = false
	
func _physics_process(delta):
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta
	if Global.player == null:
		push_error("Global.player is null")
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var distance_to_player = center.global_position.distance_to(Global.player.get_center_position())
	match current_state:
		EnemyState.WALK:
			move_towards_player(delta, distance_to_player)
		EnemyState.ATTACK:
			# Stay still for attack
			velocity = Vector2.ZERO
		EnemyState.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()

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
	enemy_animations.play("summon")
	summon_circle.show()
	await enemy_animations.animation_finished
	for i in range(spawn_amount):
		if amount_enemies_spawned < MAX_SPAWN_AMOUNT:
			# Enemies spawn with a small offset from each other
			var offset = Vector2(
				randf_range(-20, 20),  # Zufällig zwischen -20 und +20
				randf_range(-20, 20)
			)
			spawn_enemy_at("Melee_Orc", get_center_position() + offset)
			amount_enemies_spawned += 1
		else:
			pass
	summon_circle.hide()
	change_state(EnemyState.WALK)
	
func spawn_enemy_at(enemy_name, pos: Vector2):
	if enemy_name == null:
		printerr("Keine Enemy Scene zugewiesen!")
		return
	
	if enemy_name in enemy_scenes:
		var enemy = enemy_scenes[enemy_name].instantiate()
		#enemy.is_spawned_by_other_entity = true
		enemy.enemy_resource = enemy_resources[enemy_name]
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = pos
		# This is for limiting the enemy amount possibly spawned by a "spawner-enemy"
		enemy.is_spawned_by_other_entity = true
		enemy.enemy_parent = self
		Global.ProgressManager.additional_enemies += 1
	else:
		printerr("No such enemy ", enemy_name)
		printerr("Available keys: ", enemy_scenes.keys())


# Overrides enemy_base.gd
func get_center_position():
	return center.global_position
	
func move_towards_player(_delta: float, distance_to_player: float):
	# If in attack range and cooldown 0
	if distance_to_player <= get_stat("attack_range") and attack_cooldown_timer <= 0.0 and amount_enemies_spawned < MAX_SPAWN_AMOUNT:
		change_state(EnemyState.ATTACK)
		return
	# Only move if not in attack range
	if distance_to_player > get_stat("attack_range") and attack_cooldown_timer <= 0.0:
		enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
		enemy_animations.play("move")
		var direction = (Global.player.get_center_position() - center.global_position).normalized()
		velocity = direction * get_stat("movement_speed")
	else:
		# Stop moving when in attack range but cooldown >= 0
		enemy_animations.flip_h = Global.player.get_center_position().x < center.global_position.x
		enemy_animations.play("idle")
		velocity = Vector2.ZERO

func decrease_spawned_enemy_amount():
	amount_enemies_spawned = max(amount_enemies_spawned - 1, 0)
