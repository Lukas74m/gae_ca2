extends CharacterBody2D
class_name Enemy

signal died
signal attacked(player)

enum EnemyState { WALK, ATTACK, DEAD }
var current_state: EnemyState = EnemyState.WALK

@export var enemy_resource: EnemyResource
@onready var health = $Health
@onready var stats = $EnemyStats
@onready var enemy_animations: AnimatedSprite2D = $EnemyAnimations
@onready var center: Marker2D = $EnemyCenter

var attack_cooldown_timer: float = 0.0


func _ready():
	print(enemy_resource.name)
	add_to_group("enemies")
	# Giving the resource to the statsComponent to load specifix stats
	stats.initialize_stats(enemy_resource)
	# Connecting to health component
	health.initialize_health(get_stat("max_health"))
	#health.set_healthbar_position(global_position + Vector2(-15,50))
	health.died.connect(die)
	enemy_animations.frame_changed.connect(_on_attack_frame_changed)
	
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
			# Stay still for attack
			velocity = Vector2.ZERO
			if attack_cooldown_timer <= 0.0:
				change_state(EnemyState.WALK)
		EnemyState.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()
			
func move_towards_player(delta: float, distance_to_player: float):
	pass
	
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

func get_stat(stat_name: String):
	return stats.get_stat(stat_name)

# Overwritten by subclasses
func _on_attack_frame_changed():
	pass

# Overwritten by subclasses
func get_center_position():
	pass
	
# Overwritten by subclasses
func attack():
	pass
