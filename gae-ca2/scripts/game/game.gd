extends Node2D

@onready var game_timer = $Gametimer
@onready var enemy_manager = $EnemyManager
@onready var progress_manager = $ProgressManger 
@onready var task_display_instance = $CanvasLayer/TaskDisplay
@onready var player = $Player
@onready var shop = $Shop
@onready var camera = $Player/Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#enemy_manager.spawn_enemy()
	Global.player = player
	Global.ProgressManager = progress_manager
	Global.shop = shop
	Global.camera = camera
	set_task_display()
	game_timer.start()

func set_task_display():
	task_display_instance.update_display({
	"current_wave_size": Global.ProgressManager.get_level_wave_size(),
	"killed_wave_enemies": Global.ProgressManager.get_current_level_kill_amount(),
	"current_artefact_amount": Global.ProgressManager.get_current_artefact_amount(),
	"chapter_artefact_amount": Global.ProgressManager.get_chapter_artefact_amount(),
	"level": Global.ProgressManager.get_level(),
	"chapter": Global.ProgressManager.get_chapter()
})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_task_display()


func _on_gametimer_timeout() -> void:
	Global.time_alive += 1


func _on_player_player_death() -> void:
	game_timer.stop()
