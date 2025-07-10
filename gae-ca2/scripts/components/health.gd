extends Node2D

@onready var health_background = $HealthBackground
@onready var health_fill = $HealthBackground/HealthFill
var tween: Tween
var max_health: float
var current_health: float
# Height of the healtbar
const HEIGHT = 12
# Width of the healtbar
const WIDTH = 50
signal died

# Called from every entity that has the health component as an instance
func initialize_health(max_hp: float):
	max_health = max_hp
	current_health = max_hp

	health_background.size.y = HEIGHT
	health_fill.size.y = HEIGHT

	health_fill.size.x = WIDTH
	health_background.size.x = WIDTH

# Updates the healthbar visually
func update_health_bar():
	var target_width = (current_health / max_health) * WIDTH
	tween = create_tween()
	tween.tween_property(health_fill, "size:x", target_width, 0.3)

# Set the healthbar position manually because of different entity sizes
func set_healthbar_position(new_position):
	health_background.position = new_position

# Send signal to entity because it died
func die():
	emit_signal("died")

# Updates the healthpoints of the entity
# Negetive inputs are damage while positiv inputs are heal
# Also calls a method to update it visuallying
func update_health(health_change: float):
	# Secures that the entity health is between 0 and max_health
	current_health = clamp(current_health + health_change, 0, max_health)
	update_health_bar()
	if is_dead():
		die()

# Returns curretn healthpoints of entity
func get_health():
	return current_health

# Returns if entity is dead (true) or not (false)
func is_dead() -> bool:
	return current_health <= 0
