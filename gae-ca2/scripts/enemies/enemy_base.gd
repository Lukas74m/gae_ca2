extends CharacterBody2D
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
	health.set_healthbar_position(global_position + Vector2(-15,50))
	health.died.connect(die)
	
	var texture = load(enemy_resource.texture)
	enemy_visual.texture = texture
	max_health = enemy_resource.max_health
	movement_speed = enemy_resource.movement_speed
	attack_range = enemy_resource.attack_range 
	attack_damage = enemy_resource.attack_damage
	attack_cooldown = enemy_resource.attack_cooldown
	

# attack_cooldown is missing for attack
func _physics_process(delta):
	move_towards_player(delta)

func move_towards_player(delta: float):
	if Global.player == null:
		push_error("Global.player is null")
		return
	var distance_to_player = global_position.distance_to(Global.player.global_position)
	# Only move if not in attack range
	if distance_to_player > attack_range:
		var direction = (Global.player.global_position - global_position).normalized()
		velocity = direction * movement_speed
		move_and_slide()
	else:
		# Stop moving when in attack range
		velocity = Vector2.ZERO
		# Try to attack if possible
		if can_attack():
			attack()

func take_damage(amount: int):
	#current_health -= amount
	health.update_health(amount)

func die():
	queue_free()

func can_attack() -> bool:
	return global_position.distance_to(Global.player.global_position) <= attack_range

func attack():
	if can_attack():
		emit_signal("attacked")
		print("adsalfg")
