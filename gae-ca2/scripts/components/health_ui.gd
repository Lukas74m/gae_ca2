extends Node2D

@onready var health_background = %HealthBackground
@onready var health_fill = %HealthFill
var tween: Tween
var max_health = 100
var current_health = 10

func _ready():
	var desired_height = 20
	health_background.size.y = desired_height
	health_fill.size.y = desired_height
	
	# Initiale Health Bar setzen (ohne Animation)
	var initial_width = (health_background.size.x * current_health) / max_health
	health_fill.size.x = initial_width

func update_health(new_health: int):
	var target_width = (health_background.size.x * new_health) / max_health
	
	# Tween nur erstellen wenn wir ihn brauchen
	tween = create_tween()
	tween.tween_property(health_fill, "size:x", target_width, 0.3)
	current_health = new_health
