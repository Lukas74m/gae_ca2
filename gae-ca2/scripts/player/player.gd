extends CharacterBody2D

@export var speed: float = 200.0
@export var stop_distance: float = 4.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - global_position
	var distance = direction.length()

	if distance > stop_distance:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO  # Stoppt die Bewegung

	move_and_slide()
