extends CharacterBody2D

@export var speed: float = 200.0
@export var stop_distance: float = 4.0
@onready var attack_area: Area2D = $Area2D
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health = $Health

var attacking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.set_healthbar_position(global_position + Vector2(-10, 70))
	
func _input(event):
	if event.is_action_pressed("attack") and not attacking:
		attacking = true
		player_sprite.play("attack")
		perform_attack()


func _physics_process(delta: float) -> void:
	if attacking == false:
		var mouse_position = get_global_mouse_position()
		var direction = mouse_position - global_position
		var distance = direction.length()

		if distance > stop_distance:
			velocity = direction.normalized() * speed
			player_sprite.play("walk")
		else:
			velocity = Vector2.ZERO  # Stoppt die Bewegung
			player_sprite.play("idle")

		move_and_slide()
	
	
# Prüft, ob Gegner im Sichtfeld und in Angriffsreichweite sind
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


func _on_animated_sprite_2d_animation_finished() -> void:
	if player_sprite.animation == "attack":
		attacking = false
