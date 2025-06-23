extends Area2D

@export var speed: float = 200.0
@onready var timer: Timer = $Timer
var direction: Vector2 = Vector2.ZERO
var damage
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	$Timer.start(1.0) 

func initialize(_direction: Vector2, _damage: int):
	direction = _direction
	damage = _damage
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_Timer_timeout():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if !body.has_method("take_damage"):
			push_error("[Player.gd, perform_attack()] Error : body has no take_damage")
		else:
			animated_sprite_2d.play("on_hit")
			speed = 0
			body.take_damage(damage)
			print(damage) 
			#queue_free()


func _on_timer_timeout() -> void:
	queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "on_hit":
		queue_free()
