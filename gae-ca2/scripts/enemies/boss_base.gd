extends Enemy
class_name Boss

@onready var boss_animations: AnimatedSprite2D = $EnemyAnimations
@onready var boss_with_orc_animations: AnimatedSprite2D = $Boss_with_orc_animations
@onready var boss_melee: AudioStreamPlayer2D = $BossMelee
@onready var boss_dash: AudioStreamPlayer2D = $BossDash
@onready var boss_throw: AudioStreamPlayer2D = $BossThrow
@onready var boss_death: AudioStreamPlayer2D = $BossDeath
@onready var boss_melee_impact: AudioStreamPlayer2D = $BossMeleeImpact


@onready var entourage_timer = $Spawn_entourage_timer
@export var projectile_scene = preload("res://scenes/projectiles/boss_projectile.tscn")

enum BossState { WALK, RANGED_ATTACK, MELEE_ATTACK, DEAD, DASH }

var charging_melee = false
var charging_range = false
var ranged_cooldown_timer: float
var ranged_charge_timer: float
var melee_cooldown_timer: float
var melee_charge_timer: float
var boss_current_state: BossState = BossState.WALK
var dash_cooldown_timer: float
var dash_time_left: float
var dash_direction: Vector2
var amount_enemies_spawned = 0
var MAX_SPAWN_AMOUNT = 9

# Optional
var enemy_scenes = {}
var enemy_resources  = {}

# Boss has 3 phases
# 1. Melee							# Default
# 2. Melee and Range
# 3. Melee, Range and Dash
var range_ability_enabled = false	# Second phase
var dash_abilty_enabled = false		# Third phase

var meele_charge_animation = false
var meele_attack_animation = false

func load_enemy_scenes():
	enemy_scenes = {
		"Melee_Orc": preload("res://scenes/enemies/Melee_Orc.tscn"),
		"Shaman_Orc": preload("res://scenes/enemies/Shaman_Orc.tscn")
	}

# The entity names have to be the exact same like in the level.tres files
func load_enemy_resources():
	enemy_resources = {
		"Melee_Orc": preload("res://resources/enemies/melee_orc.tres"),
		"Shaman_Orc": preload("res://resources/enemies/shaman_orc.tres"),
	}
	
func _ready():
	super._ready()
	# Set initial dash cooldown to prevent immediate dashing
	dash_cooldown_timer = stats.get_stat("initial_dash_delay")
	load_enemy_scenes()
	load_enemy_resources() 

func _physics_process(delta):
	# Update cooldown timers
	if ranged_cooldown_timer > 0.0:
		ranged_cooldown_timer -= delta
	if melee_cooldown_timer > 0.0:
		melee_cooldown_timer -= delta
	if melee_charge_timer > 0.0:
		melee_charge_timer -= delta
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	if ranged_charge_timer > 0.0:
		ranged_charge_timer -= delta
		
		
	if Global.player == null:
		push_error("Global.player is null")
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var distance_to_player = center.global_position.distance_to(Global.player.get_center_position())
	
	match boss_current_state:
		BossState.WALK:
			boss_movement_logic(distance_to_player)
		BossState.RANGED_ATTACK:
			boss_animations.flip_h = Global.player.get_center_position().x < center.global_position.x
			boss_with_orc_animations.flip_h = Global.player.get_center_position().x < center.global_position.x
			if !charging_range:
				perform_ranged_charge()
			if ranged_charge_timer <= 0 and charging_range:
				charging_range = false
				perform_ranged_attack(distance_to_player)
		BossState.MELEE_ATTACK:
			boss_animations.flip_h = Global.player.get_center_position().x < center.global_position.x
			boss_with_orc_animations.flip_h = Global.player.get_center_position().x < center.global_position.x
			if !charging_melee:
				perform_melee_charge()
			if melee_charge_timer <= 0 and charging_melee:
				charging_melee = false
				perform_melee_attack(distance_to_player)
		BossState.DEAD:
			velocity = Vector2.ZERO
		BossState.DASH:
			boss_animations.flip_h = Global.player.get_center_position().x < center.global_position.x
			boss_with_orc_animations.flip_h = Global.player.get_center_position().x < center.global_position.x
			perform_dash(delta)
			
	move_and_slide()
	
	
func boss_movement_logic(distance_to_player: float):
	# Check for dash opportunity (player is far but not too far, and dash is available)
	if dash_abilty_enabled == true and distance_to_player > stats.get_stat("melee_attack_range") and distance_to_player <= stats.get_stat("dash_range") and dash_cooldown_timer <= 0.0:
		start_dash()
		return
		
	# Decide which attack to use based on distance and cooldowns
	if distance_to_player <= stats.get_stat("melee_attack_range") and melee_cooldown_timer <= 0.0:
		change_boss_state(BossState.MELEE_ATTACK)
		return
	# If phase 2 is activated and in range and out of melee range and no cooldown
	if range_ability_enabled == true and distance_to_player <= stats.get_stat("ranged_attack_range") and distance_to_player > stats.get_stat("melee_attack_range") and ranged_cooldown_timer <= 0.0:
		change_boss_state(BossState.RANGED_ATTACK)
		return
	# Move towards player
	else:
		play_boss__animation("move")
		var direction = (Global.player.center.global_position - center.global_position).normalized()
		boss_animations.flip_h = direction.x < 0
		boss_with_orc_animations.flip_h = direction.x < 0
		velocity = direction * get_stat("movement_speed")


func start_dash():
	#play_boss__animation("dash") #davor dash_charge

	#await boss_animations.animation_finished
	change_boss_state(BossState.DASH)
	dash_time_left = stats.get_stat("dash_duration")
	dash_cooldown_timer = stats.get_stat("dash_cooldown")
	dash_direction = (Global.player.center.global_position - center.global_position).normalized()
	#printerr("Boss dashing towards player", Global.time_alive)

func perform_dash(delta: float):
	play_boss__animation("dash")
	boss_dash.play()
	velocity = dash_direction * stats.get_stat("dash_speed")
	dash_time_left -= delta
	# If boss connects on player, player gets damage
	if center.global_position.distance_to(Global.player.center.global_position) <= 30:
		Global.player.take_damage(2)
	if dash_time_left <= 0.0:
		change_boss_state(BossState.WALK)


func perform_ranged_attack(_distance_to_player: float):
	play_boss__animation("range_attack")
	boss_throw.play()
	# Aim and throw projectile at player
	throw_projectile_at_player()
	# Set cooldown and return to walking
	ranged_cooldown_timer = stats.get_stat("ranged_attack_cooldown")
	change_boss_state(BossState.WALK)

func perform_ranged_charge():
	play_boss__animation("range_attack_charge")
	charging_range = true
	ranged_charge_timer = 1.2					# Have to change this. This is the projectile lifetime

func perform_melee_charge():
	play_boss__animation("melee_attack")
	boss_melee.play()
	charging_melee = true
	melee_charge_timer = stats.get_stat("melee_charge_cooldown")


func perform_melee_attack(distance_to_player: float):
	boss_melee_impact.play()
	Global.camera.shake(5)
	velocity = Vector2.ZERO
	if distance_to_player <= stats.get_stat("melee_attack_range"):
		deal_melee_damage()
	#printerr("Melle Damage ", Global.time_alive)
	# Set cooldown and return to walking
	melee_cooldown_timer = stats.get_stat("melee_attack_cooldown")
	change_boss_state(BossState.WALK)


func throw_projectile_at_player():
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	

	# Position projectile at boss location
	projectile.global_position = center.global_position
	
	# Calculate direction to player with some prediction
	var target_position = predict_player_position()

	var direction = (target_position - center.global_position).normalized()
	
	# Set projectile properties
	if projectile.has_method("initialize"):
		projectile.initialize(direction, stats.get_stat("ranged_attack_damage"), stats.get_stat("projectile_speed"))
		#projectile.ranged_attack(direction, target_position)
	

func predict_player_position() -> Vector2:
	# Simple prediction: aim slightly ahead of player based on their velocity
	var player_velocity = Vector2.ZERO
	if Global.player.has_method("get_velocity"):
		player_velocity = Global.player.get_velocity()
	else:
		printerr("No player_velocity")

	
	# Predict where player will be in 0.5 seconds
	var prediction_time = 0.5
	return Global.player.center.global_position + (player_velocity * prediction_time)

func deal_melee_damage():
	if Global.player.has_method("take_damage"):
		Global.player.take_damage(stats.get_stat("melee_attack_damage"))
		
func change_boss_state(new_state: BossState):
	if boss_current_state == new_state:
		return
		
	boss_current_state = new_state
	
	match new_state:
		BossState.RANGED_ATTACK:
			velocity = Vector2.ZERO
		BossState.MELEE_ATTACK:
			velocity = Vector2.ZERO
		BossState.DEAD:
			die()
		BossState.DASH:
			pass


# Override die method to add boss-specific death behavior
func die():
	boss_current_state = BossState.DEAD
	# Add boss death effects here (screen shake, special loot, etc.)
	boss_animations.play("death")
	boss_death.play()
	await boss_animations.animation_finished
	Global.ProgressManager.update_level_progress()
	queue_free()
	
# Overrides enemy_base.gd
func get_center_position():
	return center.global_position

# Optional: Spawns enemies
func spawn_entourage():
	for i in range(3):
		# There shouldn't be more than 10 enemies at the same time on the field
		if amount_enemies_spawned < MAX_SPAWN_AMOUNT and Global.enemies_alive < 9:
			# Enemies spawn with a small offset from each other
			var offset = Vector2(
				randf_range(-20, 20),
				randf_range(-20, 20)
			)
			spawn_enemy_at("Melee_Orc", get_center_position() + offset)
			amount_enemies_spawned += 1
		else:
			pass


# Optional 
func spawn_enemy_at(enemy_name, pos: Vector2):
	if enemy_name == null:
		printerr("No enemy scene!")
		return
	
	if enemy_name in enemy_scenes:
		var enemy = enemy_scenes[enemy_name].instantiate()
		enemy.enemy_resource = enemy_resources[enemy_name]
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = pos
		enemy.is_spawned_by_other_entity = true
		enemy.enemy_parent = self
		Global.ProgressManager.additional_enemies += 1
		Global.enemies_alive += 1
	else:
		printerr("No such enemy ", enemy_name)
		print("Available keys: ", enemy_scenes.keys())

func decrease_spawned_enemy_amount():
	amount_enemies_spawned = max(amount_enemies_spawned - 1, 0)
	
func _on_spawn_entourage_timer_timeout() -> void:
	spawn_entourage()

func play_boss__animation(animation_name : String):
		if range_ability_enabled:
			boss_with_orc_animations.play(animation_name)
		else:
			boss_animations.play(animation_name)
