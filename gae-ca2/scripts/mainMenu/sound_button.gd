extends TextureButton

@onready var player_animations: AnimatedSprite2D = $"../../PlayerAnimations"
@onready var SoundButton: AnimatedSprite2D = $AnimatedSprite2D
var start_sound_window_after_animation

func _on_ready() -> void:
	SoundButton.visible = false
	SoundButton.stop()
	start_sound_window_after_animation = false

func _on_pressed() -> void:
	SoundButton.visible = true
	SoundButton.play("click")
	player_animations.play("attack")
	start_sound_window_after_animation = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if start_sound_window_after_animation:
		get_tree().change_scene_to_file("res://scenes/soundSettings/sound_settings.tscn")
