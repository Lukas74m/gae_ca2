extends Control

@onready var title_label = $CanvasLayer/VBoxContainer/Title
@onready var vbox_container = $CanvasLayer/VBoxContainer
@onready var progress_bar = $CanvasLayer/Control/ProgressBar
@onready var to_do: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D
@onready var wave_size_info = $CanvasLayer/Control/Wave_size_info
@onready var task_size_info = $CanvasLayer/Control/Task_size_info

func update_display(information: Dictionary):
	set_labels(information)
	update_progress_bar()

func set_labels(information: Dictionary):
	var wave_enemy_information = str(information["killed_wave_enemies"]) + " von " + str(information["current_wave_size"]) + " Gegnern elemeniert"
	var wave_artefacts_information = str(information["current_artefact_amount"]) + " von " + str(information["chapter_artefact_amount"]) + " Artefakten gesammelt"
	var title = "Chapter " + str(information["chapter"]) + " : Level " + str(information["level"]) 
	# Delete all previous entries (except title)
	#for child in vbox_container.get_children():
		#if child != title_label:
			#child.queue_free()
	title_label.text = title
	wave_size_info.text = wave_enemy_information
	task_size_info.text = str(Global.enemies_alive) #wave_artefacts_information
	## Add a new stats 
	#for stat_name in stats.keys():
		#var value = stats[stat_name]
		#var label = Label.new()
		#label.text = "%s: %s" % [stat_name.capitalize(), str(value)]
		#vbox_container.add_child(label)

func update_progress_bar():
	var max_value = Global.ProgressManager.get_level_wave_size()
	var value = Global.ProgressManager.get_current_level_kill_amount()
	progress_bar.update_progress_bar(max_value, value)
