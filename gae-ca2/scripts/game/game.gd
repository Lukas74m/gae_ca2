extends Node2D

@onready var game_timer = $Gametimer
@onready var enemy_manager = $EnemyManager
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player= player
	game_timer.start()
	enemy_manager.spawn_enemy(Vector2(0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_gametimer_timeout() -> void:
	print("timeout")
