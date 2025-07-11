extends TextureButton

@onready var button: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"


func _on_ready() -> void:
	button.visible = false
	button.stop()


func _on_pressed() -> void:
	button.visible = true
	button.play("click")
	audio_stream_player_2d.play()
