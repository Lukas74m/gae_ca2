extends Node2D
class_name Enemy

signal died
signal attacked(player)

@export var enemy_resource: EnemyResource
@onready var enemy_visual = $Sprite2D

var max_health: int
var movement_speed: float
var attack_range: float
var attack_damage: float
var attack_cooldown: float

#mittelfristig weg
var current_health: int
var attack_timer := 0.0

@onready var health_bar := $HealthLogic

func _ready():
	print("SPAWNING")
	var texture = load(enemy_resource.texture)
	enemy_visual.texture = texture
	max_health = enemy_resource.max_health
	movement_speed = enemy_resource.movement_speed
	attack_range = enemy_resource.attack_range 
	attack_damage = enemy_resource.attack_damage
	attack_cooldown = enemy_resource.attack_cooldown
	
	current_health = enemy_resource.max_health

func _physics_process(delta):
	attack_timer = max(attack_timer - delta, 0)

#func move_towards(target: Vector2, delta: float):
	#var dir = (target - global_position).normalized()
	#velocity = dir * enemy_resource.movement_speed
	#move_and_slide()

func take_damage(amount: int):
	current_health -= amount
	health_bar.value = float(current_health) / enemy_resource.max_health * 100
	if current_health <= 0:
		die()

func die():
	emit_signal("died")
	queue_free()

func can_attack(target: Node2D) -> bool:
	return global_position.distance_to(target.global_position) <= enemy_resource.attack_range and attack_timer == 0

func attack(target: Node2D):
	if can_attack(target):
		attack_timer = enemy_resource.attack_cooldown
		emit_signal("attacked", target)
