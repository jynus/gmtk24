extends Node2D

@onready var exit_button : Button = %ExitButton
@onready var play_button : Button = $menuContainer/optionsContainer/buttonsContainer/PlayButton
@onready var settings := $settings

func _init():
	# Load settings config
	var user_settings = UserSettings.new()
	user_settings.load_settings()

func _ready():
	# Disable exit button if we are on the web
	if OS.get_name() == "Web":
		exit_button.hide()
	if Input.get_connected_joypads().size() > 0:
		play_button.grab_focus()
	if BackgroundMusic.current_song != "menu":
		BackgroundMusic.fade_in("menu", 0.0)

func _process(_delta):
	pass

func show_settings():
	"""Show the settings screen"""
	settings.visible = true

func show_credits():
	"""Show the credits screen"""
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func show_how_to_play_screen():
	"""Show the instructions and key bindings"""
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")
	
func _on_settings_button_pressed():
	"""Show the settings menu"""
	Fx.click.play()
	show_settings()

func exit_game():
	""""Exit to OS"""
	get_tree().quit()

func start_new_game():
	"""Start new play session"""
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_credits_button_pressed():
	Fx.click.play()
	show_credits()

func _on_exit_button_pressed():
	Fx.click.play()
	await Fx.click.finished
	exit_game()

func _on_play_button_pressed():
	Fx.click.play()
	start_new_game()


func _on_how_to_play_button_pressed() -> void:
	Fx.click.play()
	show_how_to_play_screen()
