extends Node2D
@onready var attack_skill: AnimatedSprite2D = $HBoxContainer/Attack
@onready var dash_skill: AnimatedSprite2D = $HBoxContainer/Dash
@onready var fireball: AnimatedSprite2D = $HBoxContainer/Fireball
@onready var player: CharacterBody2D = $"../../Player"
signal fireball_cooldown_finished

func _ready():
	player.attack_start.connect(_on_player_attack_start)
	player.dash_start.connect(_on_player_dash_start)
	player.fireball_start.connect(_on_player_fireball_start)
	
func _on_player_attack_start():
	attack_skill.play("cooldown")

func _on_player_dash_start():
	dash_skill.play("cooldown")
	
func _on_player_fireball_start():
	fireball.play("cooldown")
	
func _on_attack_skill_animation_finished() -> void:
	attack_skill.play("default")
	
func _on_dash_animation_finished() -> void:
	dash_skill.play("default")

func _on_fireball_animation_finished() -> void:
	emit_signal("fireball_cooldown_finished")
	fireball.play("default")
