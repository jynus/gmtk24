extends Control

const TWITTER_SHARE_URL = "https://x.com/intent/tweet?text="

@onready var expected_image: TextureRect = %expectedImage
@onready var submitted_image: TextureRect = %submittedImage
@onready var grade: TextureProgressBar = %grade
@onready var next_level_button: Button = %nextLevelButton
@onready var main_menu_button: Button = %mainMenuButton
@onready var replay_button: Button = %replayButton
@onready var share_button: TextureButton = %ShareButton

var _subject : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func level_complete(_original: Texture2D, expected: Texture2D, submitted: Texture2D, mark: int, subject: String):
	BackgroundMusic.fade_into("level_complete", 4)
	expected_image.texture = expected
	submitted_image.texture = submitted
	grade.value = mark
	_subject = subject

	if Input.get_connected_joypads().size() > 0:
		next_level_button.grab_focus()
	get_tree().create_timer(1).timeout.connect(enable_next_level_button)
	show()

func enable_next_level_button():
	next_level_button.disabled = false
	main_menu_button.disabled = false
	replay_button.disabled = false

func load_next_level():
	Fx.click.play()
	var level_select = load("res://scripts/level_select.gd")
	var ls = level_select.new()
	ls.load_next_level(get_tree())

func return_to_main_menu():
	Fx.click.play()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func reload_current_level():
	Fx.click.play()
	get_tree().reload_current_scene()


func _on_share_button_pressed() -> void:
	Fx.click.play()
	var img = submitted_image.texture.get_image()
	var resize_scale : int = 1024 / max(img.get_width(), img.get_height())
	img.resize(img.get_width() * resize_scale, img.get_height() * resize_scale, Image.INTERPOLATE_NEAREST)
	if OS.get_name() == "Web":
		var buffer := img.save_png_to_buffer()
		JavaScriptBridge.download_buffer(buffer, "%s.png" % "export", "image/png")
	else:
		img.save_png("user://export.png")
		OS.shell_open(OS.get_user_data_dir() + "/export.png")
	var url = TWITTER_SHARE_URL + (tr("Look at this beautiful image I painted with the #ScaleItDown game of a %s. Play at https://jynus.itch.io/scale-it-down") % tr(_subject)).uri_encode()
	OS.shell_open(url)

func _on_share_button_entered() -> void:
	share_button.self_modulate = Color(Color.GRAY)

func _on_share_button_exited() -> void:
	share_button.self_modulate = Color(Color.WHITE)
