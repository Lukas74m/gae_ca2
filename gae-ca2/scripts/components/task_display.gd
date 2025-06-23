extends Control

@onready var title_label = $CanvasLayer/VBoxContainer/Title
@onready var vbox_container = $CanvasLayer/VBoxContainer
@onready var progress_bar = $CanvasLayer/Control/ProgressBar
@onready var to_do: AnimatedSprite2D = $CanvasLayer/VBoxContainer/AnimatedSprite2D

	
func update_display(stats: Dictionary, title: String):
	set_labels(stats, title)
	update_progress_bar()

func set_labels(stats: Dictionary, title: String):
	# Delete all previous entries (except title)
	for child in vbox_container.get_children():
		if child != title_label:
			child.queue_free()
	title_label.text = title
	# Add a new stats 
	for stat_name in stats.keys():
		var value = stats[stat_name]
		var label = Label.new()
		label.text = "%s: %s" % [stat_name.capitalize(), str(value)]
		vbox_container.add_child(label)

func update_progress_bar():
	var max_value = Global.ProgressManager.get_level_wave_size()
	var value = Global.ProgressManager.get_current_level_kill_amount()
	progress_bar.update_progress_bar(max_value, value)
