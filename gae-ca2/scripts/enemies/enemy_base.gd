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
#var current_health: int
#var attack_timer := 0.0

@onready var health := $Health

func _ready():
	health.set_healthbar_position(global_position +  + Vector2(0,50))
	health.died.connect(die)
	
	var texture = load(enemy_resource.texture)
	enemy_visual.texture = texture
	max_health = enemy_resource.max_health
	movement_speed = enemy_resource.movement_speed
	attack_range = enemy_resource.attack_range 
	attack_damage = enemy_resource.attack_damage
	attack_cooldown = enemy_resource.attack_cooldown
	

#func _physics_process(delta):
	#attack_timer = max(attack_timer - delta, 0)


func take_damage(amount: int):
	#current_health -= amount
	health.update_health(amount)

func die():
	queue_free()

#func can_attack(target: Node2D) -> bool:
	#return global_position.distance_to(target.global_position) <= enemy_resource.attack_range and attack_timer == 0
#
#func attack(target: Node2D):
	#if can_attack(target):
		#attack_timer = enemy_resource.attack_cooldown
		#emit_signal("attacked", target)
