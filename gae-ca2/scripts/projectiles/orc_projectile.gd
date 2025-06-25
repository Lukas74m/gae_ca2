extends "res://scripts/projectiles/projectile_base.gd"

 
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if !body.has_method("take_damage"):
			push_error("Error : body has no take_damage")
		else:
			body.take_damage(10)
			animated_sprite_2d.play("on_hit")
			speed = 0



func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "on_hit":
		queue_free()
