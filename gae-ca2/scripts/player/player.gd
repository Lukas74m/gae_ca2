extends CharacterBody2D

@export var speed: float = 150.0
@export var stop_distance: float = 4.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0
@onready var attack_area: Area2D = $Area2D
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health = $Health

var is_dashing: bool = false
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var attacking: bool = false

func _ready() -> void:
	health.set_healthbar_position(global_position + Vector2(-10, 70))

#Eingabe des Spielers
func _input(event):
	if event.is_action_pressed("attack") and not attacking and not is_dashing:
		attacking = true
		player_sprite.play("attack")
		perform_attack()
		
	if event.is_action_pressed("dash") and not is_dashing and dash_cooldown_left <= 0.0:
		start_dash()

#Fuer walken, dashen und idle
func _physics_process(delta: float) -> void:
	if is_dashing:
		player_sprite.play("dash")
		velocity = dash_direction * dash_speed
		dash_time_left -= delta
		if dash_time_left <= 0.0:
			is_dashing = false
		move_and_slide()
		return  

	if dash_cooldown_left > 0.0:
		dash_cooldown_left -= delta

	# Normale Bewegung, nur wenn kein Angriff läuft
	if not attacking:
		var mouse_position = get_global_mouse_position()
		var direction = mouse_position - global_position
		var distance = direction.length()

		if distance > stop_distance:
			velocity = direction.normalized() * speed
			player_sprite.play("walk")
		else:
			velocity = Vector2.ZERO
			player_sprite.play("idle")

	move_and_slide()  

	
# Prüft, ob Gegner im Sichtfeld und in Angriffsreichweite sind + Lebensabzug der Gegner
func perform_attack():
	for body in attack_area.get_overlapping_bodies():
		print(body.name)
		#if body != self:
		if is_facing(body.global_position):
			#if body.has_method("take_damage"):
			if body.has_node("Health"): 
				body.get_node("Health").update_health(-10)
				#body.take_damage(10)
		
				
# Sichtfeldprüfung: Ist der Gegner in Blickrichtung (zur Maus)?
func is_facing(target_pos: Vector2) -> bool:
	var to_target = (target_pos - global_position).normalized()
	var to_mouse = (get_global_mouse_position() - global_position).normalized()
	return to_mouse.dot(to_target) > 0.7  
	
	
func start_dash():
	is_dashing = true
	dash_time_left = dash_duration
	dash_cooldown_left = dash_cooldown
	dash_direction = (get_global_mouse_position() - global_position).normalized()


func _on_animated_sprite_2d_animation_finished() -> void:
	if player_sprite.animation == "attack":
		attacking = false
