extends Node2D

var pixel = preload("res://scene_objects/pixel.tscn")

@onready var canvas: GridContainer = %canvas
@onready var color_picker: ColorPicker = %ColorPicker
@onready var submit_button: Button = %submitButton

@export var grid_size : Vector2i = Vector2i(1, 1)
@export var default_grid_color : Color = Color("#6a6a6a")

var _current_color : Color = Color.BLACK
var _current_pixel : Pixel
var _painting : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	BackgroundMusic.fade_into("game", 0)
	#if Input.get_connected_joypads().size() > 0:
	#	win_button.grab_focus()
	for i in range(0, grid_size.y):
		for j in range(0, grid_size.x):
			instantiate_pixel(j, i)
	color_picker.color = _current_color

func instantiate_pixel(x: int, y:int):
	var min_size : int = 50
	var button = pixel.instantiate()
	button.set_properties(Vector2i(x, y), min_size, default_grid_color)
	canvas.add_child(button)
	button.entered.connect(hover_on)
	button.exited.connect(hover_off)

func hover_on(button):
	_current_pixel = button
	if _painting and _current_pixel.color != _current_color:
		paint(button)

func hover_off(button):
	if _current_pixel == button:
		_current_pixel = null

func paint(button):
	print_debug(button.location)
	button.color = _current_color



func _on_color_picker_color_changed(color: Color) -> void:
	_current_color = color

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("paint"):
		_painting = true
		if _current_pixel != null:
			paint(_current_pixel)
	if Input.is_action_just_released("paint"):
		_painting = false

func _on_submit_button_pressed() -> void:
	for button: Pixel in canvas.get_children():
		if button.color == default_grid_color:
			print_debug("Are you sure? This button is still in the default color: ", str(button.location))
			%ConfirmationDialog.show()
		else:
			level_complete()

func level_complete() -> void:
	%LevelCompleteScreen.level_complete()
