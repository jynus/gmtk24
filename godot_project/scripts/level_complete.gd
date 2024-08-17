extends Control

@onready var next_level_button: Button = %nextLevelButton
@onready var main_menu_button: Button = %mainMenuButton
@onready var replay_button: Button = %replayButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func level_complete():
	show()
	BackgroundMusic.fade_into("level_complete")
	if Input.get_connected_joypads().size() > 0:
		next_level_button.grab_focus()
	get_tree().create_timer(1).timeout.connect(enable_next_level_button)

func enable_next_level_button():
	next_level_button.disabled = false
	main_menu_button.disabled = false
	replay_button.disabled = false

func load_next_level():
	pass

func return_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func reload_current_level():
	get_tree().reload_current_scene()
