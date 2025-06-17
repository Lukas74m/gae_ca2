extends Panel

@onready var stats_display_instance = $StatsDisplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats_display_instance.set_stats({
	"Überlebte Zeit ": Global.time_alive,
	"Getötete Gegner ": Global.kills,
	"Score ": Global.score	
}, "Statistics")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
