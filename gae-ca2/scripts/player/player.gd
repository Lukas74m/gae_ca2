extends CharacterBody2D
class_name Player

enum PlayerState { IDLE, WALK, DASH, ATTACK, DEAD, FIREBALL }
var current_state: PlayerState = PlayerState.IDLE

signal attack_start
signal dash_start
signal fireball_start

const STOP_DISTANCE: float = 12.0
const START_DISTANCE: float = 20.0
const DASH_DURATION: float = 0.2
const DASH_COOLDOWN: float = 1.0

@onready var sword_sound_1: AudioStreamPlayer2D = $SwordSound1
@onready var sword_sound_2: AudioStreamPlayer2D = $SwordSound2
@onready var sword_sound_3: AudioStreamPlayer2D = $SwordSound3
@onready var sword_sounds = [
	sword_sound_2,
	sword_sound_3
]
@onready var dash: AudioStreamPlayer2D = $Dash
@onready var fire_ball_sound: AudioStreamPlayer2D = $FireBallSound
@onready var fireball_scene = preload("res://scenes/projectiles/Fire_Ball.tscn")
@onready var stats = $PlayerStats
@onready var attack_area: Area2D = $Area2D
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health = $Health
@onready var center = $PlayerCenter
@onready var player_center: Marker2D = $PlayerCenter
@onready var skillbar: Node2D = $"../CanvasLayer/Skillbar"
@export var dash_ghost_scene: PackedScene


var ghost_spawn_interval := 0.05
var ghost_timer := 0.0
var is_dashing: bool = false
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var attacking: bool = false
var can_fireball: bool = true

func _ready() -> void:
	health.initialize_health(get_stat("max_health"))
	#health.set_healthbar_position(global_position + Vector2(-45, -40))
	skillbar.fireball_cooldown_finished.connect(_on_fireball_cooldown_finished)
	
func _input(event: InputEvent) -> void:
	# Nur im passenden Zustand auf Inputs reagieren.
	if current_state == PlayerState.IDLE or current_state == PlayerState.WALK:
		if event.is_action_pressed("attack"):
			change_state(PlayerState.ATTACK)
		elif event.is_action_pressed("dash") and dash_cooldown_left <= 0.0:
			start_dash()
		elif event.is_action_pressed("fireball") and can_fireball == true:
			change_state(PlayerState.FIREBALL)

# Walk, dashen and idle
func _physics_process(delta: float) -> void:
	if dash_cooldown_left > 0.0:
		dash_cooldown_left -= delta
	match current_state:
		PlayerState.IDLE:
			velocity = Vector2.ZERO
			player_sprite.play("idle")
			# check if player should walk
			check_movement_input()
	
		PlayerState.WALK:
			var mouse_position = get_global_mouse_position()
			var direction = mouse_position - player_center.global_position
			var distance = direction.length()
			if distance > START_DISTANCE:
				velocity = direction.normalized() * get_stat("movement_speed")
				player_sprite.play("move")
			elif distance < STOP_DISTANCE:
				velocity = Vector2.ZERO
				change_state(PlayerState.IDLE)
		
		PlayerState.ATTACK:
			velocity = Vector2.ZERO
		
		PlayerState.FIREBALL:
			velocity = Vector2.ZERO
		
		PlayerState.DASH:
			player_sprite.play("dash")
			velocity = dash_direction * get_stat("dash_speed")
			ghost_timer -= delta
			if ghost_timer <= 0.0:
				spawn_dash_ghost()
				ghost_timer = ghost_spawn_interval
			dash_time_left -= delta
			if dash_time_left <= 0.0:
				change_state(PlayerState.IDLE)
		
		PlayerState.DEAD:
			velocity = Vector2.ZERO
	var mouse_direction = get_global_mouse_position()
	player_sprite.flip_h = mouse_direction.x < player_center.global_position.x
	move_and_slide()  	

# Helpmethod to change states
func change_state(new_state: PlayerState) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	match new_state:
		PlayerState.ATTACK:
			player_sprite.play("attack")
			attack()
		PlayerState.FIREBALL:
			player_sprite.play("fireball")
			shoot_fireball()
			
func check_movement_input() -> void:
	var mouse_position = get_global_mouse_position()
	if (mouse_position - player_center.global_position).length() > STOP_DISTANCE:
		change_state(PlayerState.WALK)

# Checks if enemies are in the right direction and attack range
# If true, do damage to the enemy
func attack():
	emit_signal("attack_start")
	var random_index = randi() % sword_sounds.size()
	sword_sounds[random_index].play()
	for body in attack_area.get_overlapping_bodies():
		# Must be an enemy
		if body.is_in_group("enemies"):
			if is_facing(body.get_center_position()):
				# Debug
				if !body.has_method("take_damage"):
					push_error("[Player.gd, perform_attack()] Error : body has no take_damage")
				else: 
					var attack_damage = get_stat("attack_damage")
					var crit_damage = get_stat("crit_damage")
					var crit_rate = get_stat("crit_rate")
					var is_crit = randf() < crit_rate
					var total_damage = attack_damage
					if is_crit:
						total_damage *= crit_damage
					body.take_damage(total_damage)

# Checks if the enemy is in view direction of the player (If mouse points in enemy direction)
func is_facing(target_pos: Vector2) -> bool:
	var to_target = (target_pos - player_center.global_position).normalized()
	var to_mouse = (get_global_mouse_position() - player_center.global_position).normalized()
	return to_mouse.dot(to_target) > 0.7  
	
	
func start_dash():
	change_state(PlayerState.DASH)
	emit_signal("dash_start")
	dash.play()
	dash_time_left = DASH_DURATION
	dash_cooldown_left = DASH_COOLDOWN
	dash_direction = (get_global_mouse_position() - player_center.global_position).normalized()


func _on_animated_sprite_2d_animation_finished() -> void:
	if player_sprite.animation == "attack" or player_sprite.animation == "fireball":
		change_state(PlayerState.IDLE)

func take_damage(amount: int):
	health.update_health(-amount)
	
func get_stat(stat_name: String):
	return stats.get_stat(stat_name)

func get_center_position() -> Vector2:
	return player_center.global_position

# Player dies
func _on_health_died() -> void:
	change_state(PlayerState.DEAD)
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://scenes/deathscreen/Deathscreen.tscn")

func spawn_dash_ghost():
	var ghost = dash_ghost_scene.instantiate() as Sprite2D
	ghost.texture = player_sprite.sprite_frames.get_frame_texture(player_sprite.animation, player_sprite.frame)
	ghost.global_position = player_center.global_position
	ghost.flip_h = player_sprite.flip_h
	get_parent().add_child(ghost)


# Heals the player by a certain amount in percent
# If player currently has 20/100 HP and method is called with 0.5,
# 0.5 percent of the players max health is added to the current health
# -> 20 + 0.5 * 100 (example max_health) = 70 for the new health
func heal_player(heal_percentage: float):
	var healing_amount = get_stat("max_health") * heal_percentage
	health.update_health(healing_amount)


func shoot_fireball():
	emit_signal("fireball_start")
	fire_ball_sound.play()
	can_fireball = false
	var fireball = fireball_scene.instantiate()
	fireball.global_position = player_center.global_position 
	fireball.initialize(
		(get_global_mouse_position() - fireball.global_position).normalized(),
		get_stat("fireball_damage"), 200 # Speed
	)
	get_tree().current_scene.add_child(fireball)

func _on_fireball_cooldown_finished():
	can_fireball = true
