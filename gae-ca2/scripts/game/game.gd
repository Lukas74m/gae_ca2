extends Node2D

@onready var game_timer = $Gametimer
@onready var enemy_manager = $EnemyManager
@onready var progress_manager = $ProgressManger 
@onready var player = $Player
@onready var shop: CanvasLayer = $Shop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#enemy_manager.spawn_enemy()
	Global.player = player
	Global.ProgressManager = progress_manager
	game_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_gametimer_timeout() -> void:
	#print("timeout")
	pass
