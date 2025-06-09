extends TextureButton

@onready var QuitButton: AnimatedSprite2D = $AnimatedSprite2D
var quit_game_after_animation = false


func _on_ready() -> void:
	QuitButton.visible = false
	QuitButton.stop()


func _on_pressed() -> void:
	QuitButton.visible = true
	QuitButton.play("click")
	quit_game_after_animation = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if quit_game_after_animation:
		get_tree().quit()
