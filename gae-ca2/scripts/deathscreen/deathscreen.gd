extends Panel

@onready var stats_display_instance = $Control/StatsDisplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats_display_instance.update_display({
	"Überlebte Zeit ": Global.time_alive,
	"Getötete Gegner ": Global.kills,
	"Score ": Global.score	
}, "Statistik")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
