extends Area2D

@export var speed: float
@onready var timer: Timer = $Timer
var direction: Vector2 = Vector2.ZERO
var damage
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	$Timer.start()

func initialize(_direction: Vector2, _damage: int, _speed: int):
	direction = _direction
	damage = _damage
	speed = _speed
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

# Overwritten by subclasses
func _on_body_entered(body: Node2D) -> void:
	pass

# Overwritten by subclasses
func _on_animated_sprite_2d_animation_finished() -> void:
	pass

func _on_timer_timeout() -> void:
	queue_free()
