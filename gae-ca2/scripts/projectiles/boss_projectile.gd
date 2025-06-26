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

# Currently not used
# Might be used later
# Don't delete yet
func adjust_direction() -> void:
	var projectile_flying = true
	while projectile_flying == true:
		var direction = (Global.player.global_position - global_position).normalized()
		global_position += direction * 7
		
		if Global.player.global_position.distance_to(global_position) <= 20:
			# * Global.player.get_stat("movement_speed") for the calculation below
			var player_position_prediction = (get_global_mouse_position() - Global.player.global_position).normalized()
			global_position += player_position_prediction * 7
			await get_tree().create_timer(1).timeout
			if Global.player.global_position.distance_to(global_position) <= 20:
				Global.player.take_damage(20)
				projectile_flying = false
			queue_free()
		await get_tree().create_timer(0.1).timeout
