extends Node2D

var pixel = preload("res://scene_objects/pixel.tscn")
@onready var original: TextureRect = %original
@onready var canvas: GridContainer = %canvas
@onready var color_picker: ColorPicker = %ColorPicker
@onready var submit_button: Button = %submitButton
@onready var title: Label = %Title

@export var subject: String
@export var grid_size : Vector2i = Vector2i(1, 1)
@export var pixel_separation : int = 3
@export var default_grid_color : Color = Color("#6a6a6a")
@export var original_drawing : Texture2D
@export var expected_result : Texture2D

var _current_color : Color = Color.HOT_PINK
var _current_pixel : Pixel
var _painting : bool = false
var _erasing : bool = false
var _min_size : int = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	BackgroundMusic.fade_into("game", 0)
	#if Input.get_connected_joypads().size() > 0:
	#	win_button.grab_focus()
	title.text = tr("Draw: ") + tr(subject)
	canvas.columns = grid_size.x
	canvas.add_theme_constant_override("v_separation", pixel_separation)
	canvas.add_theme_constant_override("h_separation", pixel_separation)
	_min_size = canvas.custom_minimum_size.x / max(grid_size.x, grid_size.y) - pixel_separation
	for i in range(0, grid_size.y):
		for j in range(0, grid_size.x):
			instantiate_pixel(j, i)
	color_picker.color = _current_color
	original.texture = original_drawing

func instantiate_pixel(x: int, y:int):
	var button = pixel.instantiate()
	button.set_properties(Vector2i(x, y), _min_size, default_grid_color)
	button.name = "Pixel" + str(x) + "-" + str(y)
	canvas.add_child(button)
	button.entered.connect(hover_on)
	button.exited.connect(hover_off)

func hover_on(button):
	_current_pixel = button
	if _painting and _current_pixel.color != _current_color:
		paint(button)
	elif _erasing and _current_pixel.color != default_grid_color:
		erase(button)

func hover_off(button):
	if _current_pixel == button:
		_current_pixel = null

func paint(button):
	print_debug(button.location)
	button.color = _current_color

func erase(button):
	print_debug(button.location)
	button.color = default_grid_color

func _on_color_picker_color_changed(color: Color) -> void:
	_current_color = color

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("paint"):
		_painting = true
		_erasing = false
		if _current_pixel != null:
			paint(_current_pixel)
	if Input.is_action_just_released("paint"):
		_painting = false
	if Input.is_action_just_pressed("erase"):
		_erasing = true
		_painting = false
		if _current_pixel != null:
			erase(_current_pixel)
	if Input.is_action_just_released("paint"):
		_erasing = false
	if Input.is_action_just_pressed("clone") and _current_pixel != null:
		color_picker.color = _current_pixel.color
		_current_color = _current_pixel.color
		_painting = false
		_erasing = false


func _on_submit_button_pressed() -> void:
	Fx.click.play()
	for button: Pixel in canvas.get_children():
		if button.color == default_grid_color:
			print_debug("Are you sure? This button is still in the default color: ", str(button.location))
			%ConfirmationDialog.show()
			return
	level_complete()

func level_complete() -> void:
	var img_submitted = Image.create(grid_size.x, grid_size.y, false, Image.FORMAT_RGB8)
	var img_expected = expected_result.get_image()
	var pixels : Array = canvas.get_children()
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var p : Pixel = pixels.pop_front()
			img_submitted.set_pixel(x, y, p.color)
	var submitted_result : Texture2D = ImageTexture.create_from_image(img_submitted)
	var mark : int = grade_image(img_expected, img_submitted)
	%LevelCompleteScreen.level_complete(original_drawing, expected_result, submitted_result, mark, subject)

func grade_image(img_expected: Image, img_submitted: Image):
	var pixel_expected : Color
	var pixel_submitted : Color
	var difference : int
	var total_difference : int = 0
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			pixel_expected = img_expected.get_pixel(x, y)
			pixel_submitted = img_submitted.get_pixel(x, y)
			difference = max(abs(pixel_expected.r8 - pixel_submitted.r8), \
							 abs(pixel_expected.g8 - pixel_submitted.g8), \
							 abs(pixel_expected.b8 - pixel_submitted.b8))
			total_difference += difference
	var avg_difference = float(total_difference) / grid_size.x / grid_size.y
	print_debug("avg difference: ", avg_difference)
	if avg_difference >= 100:
		return 0
	elif avg_difference >= 80:
		return 1
	elif avg_difference >= 60:
		return 2
	elif avg_difference >= 50:
		return 3
	elif avg_difference >= 40:
		return 5
	elif avg_difference >= 30:
		return 7
	elif avg_difference >= 20:
		return 8
	elif avg_difference >= 10:
		return 9
	else:
		return 10
