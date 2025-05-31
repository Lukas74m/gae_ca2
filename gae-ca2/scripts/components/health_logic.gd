extends Node2D

var entity_max_health : float
var entity_current_health : float
signal died


func die():
	# Send to the specific entity, for example the player
	emit_signal("died")

func update_health(healt_change: float):
	# Secures that the entity health is between 0  and entity_max_health
	entity_current_health = clamp(entity_current_health + healt_change, 0 , entity_max_health)
	if entity_current_health <= 0:
		die()

func get_health():
	return entity_current_health

func isdead() -> bool:
	return entity_current_health <= 0
