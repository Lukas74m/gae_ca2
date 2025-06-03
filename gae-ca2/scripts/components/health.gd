extends Node2D

@onready var health_background = $HealthBackground
@onready var health_fill = $HealthBackground/HealthFill
var tween: Tween
var max_health: float
var current_health: float
signal died


func _ready():
	var desired_height = 12
	health_background.size.y = desired_height
	health_fill.size.y = desired_height

func initialize_health(max_hp: float, current_hp: float):
	max_health = max_hp
	current_health = current_hp

	var initial_width = (health_background.size.x * current_health) / max_health
	health_fill.size.x = initial_width

func update_health_bar():
	var target_width = (health_background.size.x * current_health) / max_health
	
	tween = create_tween()
	tween.tween_property(health_fill, "size:x", target_width, 0.3)

func set_healthbar_position(position):
	health_background.position = position

func die():
	emit_signal("died")

func update_health(health_change: float):
	# Secures that the entity health is between 0 and max_health
	current_health = clamp(current_health + health_change, 0, max_health)
	update_health_bar()
	if current_health <= 0:
		die()

func get_health():
	return current_health

func is_dead() -> bool:
	return current_health <= 0
