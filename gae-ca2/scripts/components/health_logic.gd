extends Node2D

var max_health: float
var current_health: float
signal died

func die():
	emit_signal("died")

func update_health(health_change: float):
	# Secures that the entity health is between 0 and max_health
	current_health = clamp(current_health + health_change, 0, max_health)
	if current_health <= 0:
		die()

func get_health():
	return current_health

func is_dead() -> bool:
	return current_health <= 0
	

