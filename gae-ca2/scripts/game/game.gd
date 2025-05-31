extends Node2D

@onready var health_bar = $HealthUi
@onready var game_timer = $Gametimer
var health = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_gametimer_timeout() -> void:
	print("timeout")
	health += 10
	health_bar.update_health(25)
