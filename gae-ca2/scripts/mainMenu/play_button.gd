extends TextureButton

@onready var player_animations: AnimatedSprite2D = $"../../PlayerAnimations"
@onready var PlayButton: AnimatedSprite2D = $AnimatedSprite2D
var start_game_after_animation = false


func _on_ready() -> void:
	PlayButton.visible = false
	PlayButton.stop()


func _on_pressed() -> void:
	PlayButton.visible = true
	PlayButton.play("click")
	player_animations.play("attack")
	start_game_after_animation = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if start_game_after_animation:
		get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
