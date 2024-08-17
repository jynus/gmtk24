extends Node3D

@onready var original_marker: Marker3D = %originalMarker
@onready var working_marker: Marker3D = %workingMarker
@onready var original_camera: Camera3D = %originalCamera
@onready var working_camera: Camera3D = %workingCamera


var _dragging = false
var _dragging_source: Vector2i = Vector2i.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BackgroundMusic.fade_into("game", 0)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("paint"):
		_dragging = true
		_dragging_source = get_viewport().get_mouse_position()
	if Input.is_action_just_released("paint"):
		_dragging = false
	if Input.is_action_just_pressed("zoom_in"):
		zoom_in()
	if Input.is_action_just_pressed("zoom_out"):
		zoom_out()

	if _dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		if abs(_dragging_source.x - mouse_pos.x) > 10:
			rotate_models((_dragging_source.x - mouse_pos.x) / 10.0)
			_dragging_source.x = mouse_pos.x
		if abs(_dragging_source.y - mouse_pos.y) > 10:
			move_down((mouse_pos.y - _dragging_source.y) / 10.0)
			_dragging_source.y = mouse_pos.y

func rotate_models(degrees: float):
	original_marker.rotate(Vector3.UP, deg_to_rad(degrees))
	working_marker.rotate(Vector3.UP, deg_to_rad(degrees))

func zoom_in():
	original_camera.fov += 3
	if original_camera.fov > 100:
		original_camera.fov = 100
	working_camera.fov = original_camera.fov

func zoom_out():
	original_camera.fov -= 3
	if original_camera.fov < 0.5:
		original_camera.fov = 0.5
	working_camera.fov = original_camera.fov

func move_down(offset: int = 2):
	original_camera.v_offset += offset
	if original_camera.v_offset < -100:
		original_camera.v_offset = -100
	if original_camera.v_offset > 100:
		original_camera.v_offset = 100
	working_camera.v_offset = original_camera.v_offset

func move_up(offset: int = 2):
	move_down(-offset)

func _on_left_button_pressed() -> void:
	rotate_models(10)

func _on_right_button_pressed() -> void:
	rotate_models(-10)

func _on_up_button_pressed() -> void:
	move_up()

func _on_down_button_pressed() -> void:
	move_down()
