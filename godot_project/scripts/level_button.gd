extends Button

@export var level : String

signal level_select(level)

func _on_pressed():
	level_select.emit(level)
