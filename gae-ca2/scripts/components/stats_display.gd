extends Control

@onready var title_label = $VBoxContainer/Title
@onready var vbox_container = $VBoxContainer
	
func _ready() -> void:
	print("Size:", size)
	

func set_stats(stats: Dictionary, title: String ):
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
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox_container.add_child(label)
