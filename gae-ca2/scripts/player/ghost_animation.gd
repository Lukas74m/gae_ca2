extends Sprite2D

@export var fade_duration := 0.3
var fade_timer := 0.0

func _ready():
	fade_timer = fade_duration
	modulate.a = 0.6  # Anfangstransparenz

func _process(delta):
	fade_timer -= delta
	modulate.a = fade_timer / fade_duration
	if fade_timer <= 0.0:
		queue_free()
