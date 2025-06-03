extends Node2D

@onready var health = $Health
@onready var game_timer = $Gametimer
@onready var enemy_manager = $EnemyManager
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player= player
	game_timer.start()
	health.max_health = 100
	health.current_health = 100
	enemy_manager.spawn_enemy(Vector2(0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_gametimer_timeout() -> void:
	print("timeout")
	var health_update = -10
	health.update_health(health_update)
