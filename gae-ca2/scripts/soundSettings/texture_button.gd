extends TextureButton
@onready var BackButton: AnimatedSprite2D = $AnimatedSprite2D
@onready var click_sound: AudioStreamPlayer2D = $"../ClickSound"

var back_to_main_menu_after_animation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BackButton.visible = false
	BackButton.stop()
	back_to_main_menu_after_animation = false

func _on_pressed() -> void:
	click_sound.play()
	BackButton.visible = true
	BackButton.play("click")
	back_to_main_menu_after_animation = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if back_to_main_menu_after_animation:
		get_tree().change_scene_to_file("res://scenes/mainMenu/Main_Menu.tscn")
