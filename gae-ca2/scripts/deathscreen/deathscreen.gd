extends Node2D

@onready var time_alive_label = $time_alive
@onready var enemy_kills_label = $enemy_kills
@onready var score_label = $score


func _process(delta: float) -> void:
	time_alive_label.text = "Zeit überlebt: %.1f Sekunden" % Global.time_alive
	enemy_kills_label.text = "Kills: %d" % Global.kills
	score_label.text = "Score: %d" % Global.score
