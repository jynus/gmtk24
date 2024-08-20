extends Node2D

@onready var typing_sound: AudioStreamPlayer = %TypingSound
@onready var back_button: Button = %backButton
@onready var you_won_text: RichTextLabel = %youWonText

func _ready() -> void:
	BackgroundMusic.fade_into("win")
	if Input.get_connected_joypads().size() > 0:
		back_button.grab_focus()

	you_won_text.visible_ratio = 0
	typing_sound.play()
	var tween : Tween = create_tween()
	tween.finished.connect(on_animation_finish)
	tween.tween_property(you_won_text, "visible_ratio", 1, 20)

func on_animation_finish():
	typing_sound.stop()
	
func _on_back_button_pressed() -> void:
	Fx.click.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
