extends Camera2D

var shake_amount: float = 0.0
var shake_decay: float = 5.0

func _process(delta):
	if shake_amount > 0:
		offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_amount
		shake_amount = max(shake_amount - shake_decay * delta, 0)
	else:
		offset = Vector2.ZERO

func shake(power: float):
	shake_amount = power
