extends TextureButton

@onready var player_animations: AnimatedSprite2D = $"../../PlayerAnimations"
@onready var HelpButton: AnimatedSprite2D = $AnimatedSprite2D
var start_help_after_animation = false


func _on_ready() -> void:
	HelpButton.visible = false
	HelpButton.stop()


func _on_pressed() -> void:
	HelpButton.visible = true
	HelpButton.play("click")
	player_animations.play("attack")
	start_help_after_animation = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if start_help_after_animation:
		get_tree().change_scene_to_file("res://scenes/helpSettings/help_settings.tscn")
