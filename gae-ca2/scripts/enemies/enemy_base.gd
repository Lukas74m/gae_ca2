extends CharacterBody2D
class_name Enemy

signal died
signal attacked(player)

enum EnemyState { WALK, ATTACK, DEAD }
var current_state: EnemyState = EnemyState.WALK

@export var enemy_resource: EnemyResource
@export var sprite_path: NodePath
@export var center_path: NodePath
@onready var enemy_visual = $Sprite2D
@onready var health := $Health
@onready var sprite: AnimatedSprite2D = get_node(sprite_path)
@onready var center: Marker2D = get_node(center_path)

var max_health: int
var movement_speed: float
var attack_range: float
var attack_damage: float
var attack_cooldown: float

var attack_cooldown_timer: float = 0.0

func _ready():
	max_health = enemy_resource.max_health
	movement_speed = enemy_resource.movement_speed
	attack_range = enemy_resource.attack_range 
	attack_damage = enemy_resource.attack_damage
	attack_cooldown = enemy_resource.attack_cooldown
	
	health.initialize_health(max_health)
	health.set_healthbar_position(global_position + Vector2(-15,50))
	health.died.connect(die)
	sprite.frame_changed.connect(_on_attack_frame_changed)
	
func _physics_process(delta):
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta
	if Global.player == null:
		push_error("Global.player is null")
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var distance_to_player = global_position.distance_to(Global.player.get_center_position())
	match current_state:
		EnemyState.WALK:
			move_towards_player(delta, distance_to_player)
		EnemyState.ATTACK:
			attack_player(delta, distance_to_player)
			if attack_cooldown_timer <= 0.0:
				change_state(EnemyState.WALK)
		EnemyState.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()
			
func move_towards_player(delta: float, distance_to_player: float):
	# If in attack range and cooldown 0
	if distance_to_player <= attack_range and attack_cooldown_timer <= 0.0:
		change_state(EnemyState.ATTACK)
		return
	# Only move if not in attack range
	if distance_to_player > attack_range and attack_cooldown_timer <= 0.0:
		sprite.flip_h = Global.player.get_center_position().x < global_position.x
		sprite.play("move")
		var direction = (Global.player.get_center_position() - global_position).normalized()
		velocity = direction * movement_speed
	else:
		# Stop moving when in attack range but cooldown >= 0
		sprite.flip_h = Global.player.get_center_position().x < global_position.x
		sprite.play("idle")
		velocity = Vector2.ZERO

func attack_player(delta:float, distance_to_player: float):
	velocity = Vector2.ZERO
	#if distance_to_player > enemy_resource.attack_range:
		#change_state(EnemyState.WALK)

func change_state(new_state: EnemyState):
	if current_state == new_state:
		return
		
	current_state = new_state
	
	match new_state:
		EnemyState.ATTACK:
			attack()
		EnemyState.DEAD:
			die()
		
func take_damage(amount: int):
	health.update_health(-amount)

func die():
	Global.kills += 1
	Global.ProgressManager.update_level_progress()
	queue_free()
	
func get_center_position() -> Vector2:
	return center.global_position

#func can_attack() -> bool:
#	return global_position.distance_to(Global.player.global_position) <= attack_range

func attack():
	sprite.flip_h = Global.player.get_center_position().x < global_position.x
	sprite.play("attack")
	attack_cooldown_timer = attack_cooldown 
	await sprite.animation_finished
	sprite.play("idle")

func _on_attack_frame_changed():
	if sprite.animation == "attack" and sprite.frame == 10:
		var distance = global_position.distance_to(Global.player.get_center_position())
		if distance <= attack_range:
			Global.player.take_damage(attack_damage)
