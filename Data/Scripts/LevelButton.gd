extends Button

signal next_level

var level_path

func _ready():
# warning-ignore:return_value_discarded
	connect("next_level", get_node("../../.."), "_next_level")

func _on_LevelButton_pressed():
	emit_signal("next_level", level_path)
