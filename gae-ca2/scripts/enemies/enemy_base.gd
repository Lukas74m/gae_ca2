extends CharacterBody2D
class_name Enemy

enum EnemyState { WALK, ATTACK, DEAD }
var current_state: EnemyState = EnemyState.WALK
var is_spawned_by_other_entity = false
var enemy_parent = null

@onready var damage_popup = preload("res://scenes/components/DamagePopUp.tscn")
@export var enemy_resource: EnemyResource
@onready var health = $Health
@onready var stats = $EnemyStats
@onready var enemy_animations: AnimatedSprite2D = $EnemyAnimations
@onready var center: Marker2D = $EnemyCenter

var attack_cooldown_timer: float = 0.0

func _ready():
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
		
	var distance_to_player = center.global_position.distance_to(Global.player.get_center_position())
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
			
func move_towards_player(_delta: float, _distance_to_player: float):
	pass
	
func change_state(new_state: EnemyState):
	if current_state == new_state:
		return
		
	current_state = new_state
	
	match new_state:
		EnemyState.ATTACK:
			attack()
		EnemyState.DEAD:
			death()
	
func take_damage(amount: int, is_crit: bool):
	show_damage(amount, is_crit)
	health.update_health(-amount)
	
func die():
	change_state(EnemyState.DEAD)
	
# Overwritten by subclasses
func death():
	pass

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
	
# Increases enemy stats by certain percentage
# Called from enemyManager
func increase_stats(increase_mult : float):
	stats.apply_mult_modifier("attack_damage", increase_mult)
	stats.apply_mult_modifier("max_health", increase_mult)
	health.initialize_health(get_stat("max_health"))
	printerr("New: ", stats.get_stat("attack_damage"))
	printerr("New: ", stats.get_stat("max_health"))
	printerr("Current: ", stats.get_stat("max_health"))
	
func reset_stats():
	pass

func show_damage(amount: int, is_crit: bool):
	var popup = damage_popup.instantiate()
	popup.position = get_center_position() + Vector2(randf_range(-10, 10), -10)
	popup.get_node("Label").text = str(amount)
	# Crit has a different color and is bigger sized
	if is_crit:
		# New settings so the color/size adjusments don't effect the original one
		var old_settings = popup.get_node("Label").label_settings
		var new_settings = old_settings.duplicate()
		new_settings.font_size = 21
		new_settings.outline_color = Color.YELLOW
		popup.get_node("Label").label_settings = new_settings
	get_tree().current_scene.add_child(popup)
