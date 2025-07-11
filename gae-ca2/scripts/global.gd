extends Node

var player
var ProgressManager
var shop
var camera
var map_area

var kills: int = 0:
	set(value):
		kills = value
		
var score: int = 0:
	set(value):
		score = value

var time_alive: int = 0:
	set(value):
		time_alive = value

var enemies_alive: int = 0:
	set(value):
		enemies_alive = value

func go_to_deathscreen():
	get_tree().change_scene_to_file("res://scenes/deathscreen/deathscreen.tscn")
