extends CharacterBody2D

const STOP_DISTANCE: float = 10.0
const DASH_DURATION: float = 0.2
const DASH_COOLDOWN: float = 1.0

@onready var stats = $PlayerStats
@onready var attack_area: Area2D = $Area2D
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health = $Health

var is_dashing: bool = false
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var attacking: bool = false

func _ready() -> void:
	#health.died.connect(die)		# Enable this later
	health.initialize_health(get_stat("max_health"))
	health.set_healthbar_position(global_position + Vector2(-45, -40))

# Player keyboard inputs
func _input(event):
	if event.is_action_pressed("attack") and not attacking and not is_dashing:
		attacking = true
		player_sprite.play("attack")
		perform_attack()
		
	if event.is_action_pressed("dash") and not is_dashing and dash_cooldown_left <= 0.0:
		start_dash()


# Walk, dashen and idle
func _physics_process(delta: float) -> void:
	if is_dashing:
		player_sprite.play("dash")
		velocity = dash_direction * get_stat("dash_speed")
		dash_time_left -= delta
		if dash_time_left <= 0.0:
			is_dashing = false
		move_and_slide()
		return  

	if dash_cooldown_left > 0.0:
		dash_cooldown_left -= delta

	# Normal movement, only if player is doing nothing else
	if not attacking:
		var mouse_position = get_global_mouse_position()
		var direction = mouse_position - global_position
		var distance = direction.length()

		if distance > STOP_DISTANCE:
			velocity = direction.normalized() * get_stat("movement_speed")
			player_sprite.play("walk")
		else:
			velocity = Vector2.ZERO
			player_sprite.play("idle")
			
	move_and_slide()  


# Checks if enemies are in the right direction and attack range
# If true, do damage to the enemy
func perform_attack():
	for body in attack_area.get_overlapping_bodies():
		# Must be an enemy
		if body.is_in_group("enemies"):
			if is_facing(body.global_position):
				# Debug
				if !body.has_method("take_damage"):
					push_error("[Player.gd, perform_attack()] Error : body has no take_damage")
				else: 
					body.take_damage(get_stat("attack_damage"))


# Checks if the enemy is in view direction of the player (If mouse points in enemy direction)
func is_facing(target_pos: Vector2) -> bool:
	var to_target = (target_pos - global_position).normalized()
	var to_mouse = (get_global_mouse_position() - global_position).normalized()
	return to_mouse.dot(to_target) > 0.7  
	
	
func start_dash():
	is_dashing = true
	dash_time_left = DASH_DURATION
	dash_cooldown_left = DASH_COOLDOWN
	dash_direction = (get_global_mouse_position() - global_position).normalized()


func _on_animated_sprite_2d_animation_finished() -> void:
	if player_sprite.animation == "attack":
		attacking = false

func take_damage(amount: int):
	health.update_health(-amount)
	
func get_stat(stat_name: String):
	return stats.get_stat(stat_name)

#func die():
	#queue_free()
