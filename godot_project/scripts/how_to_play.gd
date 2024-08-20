extends Node2D
@onready var back_button: Button = %backButton

func _ready() -> void:
	if Input.get_connected_joypads().size() > 0:
		back_button.grab_focus()

func _on_back_button_pressed() -> void:
	Fx.click.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
