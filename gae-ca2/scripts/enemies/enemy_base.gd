extends CharacterBody2D
class_name Enemy

signal died
signal attacked(player)

@export var config: EnemyResource

var current_health: int
var attack_timer := 0.0

@onready var health_bar := $HealthLogic

func _ready():
	current_health = config.max_health

func _physics_process(delta):
	attack_timer = max(attack_timer - delta, 0)

func move_towards(target: Vector2, delta: float):
	var dir = (target - global_position).normalized()
	velocity = dir * config.movement_speed
	move_and_slide()

func take_damage(amount: int):
	current_health -= amount
	health_bar.value = float(current_health) / config.max_health * 100
	if current_health <= 0:
		die()

func die():
	emit_signal("died")
	queue_free()

func can_attack(target: Node2D) -> bool:
	return global_position.distance_to(target.global_position) <= config.attack_range and attack_timer == 0

func attack(target: Node2D):
	if can_attack(target):
		attack_timer = config.attack_cooldown
		emit_signal("attacked", target)
