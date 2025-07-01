extends "res://scripts/enemies/enemy_base.gd"

#@onready var fireball_scene = preload("res://scenes/projectiles/Orc_Projectile.tscn")
@onready var arrow_scene = preload("res://scenes/projectiles/arrow.tscn")

@onready var bow: AnimatedSprite2D = $Bow
@onready var enemy_center = $EnemyCenter

signal fireball_start

var can_fireball: bool = true

func _ready():
	super._ready()

# Overrides enemy_base.gd
func attack():
	enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
	enemy_animations.play("shoot")
	bow.play("bow")
	attack_cooldown_timer = get_stat("attack_cooldown")
	#await enemy_animations.animation_finished
	can_fireball = false
	var arrow = arrow_scene.instantiate()
	arrow.global_position = enemy_center.global_position 
	arrow.initialize(
		(Global.player.global_position - arrow.global_position).normalized(),
		get_stat("fireball_damage"), 125 #Speed
	)
	get_tree().current_scene.add_child(arrow)

func _on_fireball_cooldown_finished():
	can_fireball = true

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
		enemy_animations.play("move")
		var direction = (Global.player.get_center_position() - global_position).normalized()
		velocity = direction * get_stat("movement_speed")
	else:
		# Stop moving when in attack range but cooldown >= 0
		enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
		enemy_animations.play("idle")
		velocity = Vector2.ZERO
