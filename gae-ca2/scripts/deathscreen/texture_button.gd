extends TextureButton
@onready var deathscreen_button: AnimatedSprite2D = $AnimatedSprite2D
var start_menu_after_animation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deathscreen_button.visible = false
	deathscreen_button.stop()
	start_menu_after_animation = false

func _on_pressed() -> void:
	deathscreen_button.visible = true
	deathscreen_button.play("click")
	start_menu_after_animation = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if start_menu_after_animation:
		MenuMusic.play()
		get_tree().change_scene_to_file("res://scenes/mainMenu/Main_Menu.tscn")
