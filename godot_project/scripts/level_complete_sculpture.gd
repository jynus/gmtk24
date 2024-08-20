extends Control

const TWITTER_SHARE_URL = "https://x.com/intent/tweet?text="


@onready var expected_marker: Marker3D = %expectedMarker
@onready var submitted_marker: Marker3D = %submittedMarker
@onready var submitted_sub_viewport: SubViewport = %submittedSubViewport
@onready var expected_camera: Camera3D = %expectedCamera
@onready var submitted_camera: Camera3D = %submittedCamera
@onready var grade: TextureProgressBar = %grade
@onready var next_level_button: Button = %nextLevelButton
@onready var main_menu_button: Button = %mainMenuButton
@onready var replay_button: Button = %replayButton
@onready var share_button: TextureButton = %ShareButton
@onready var submitted_grid: GridMap = %submittedGrid

var _original_mesh : Mesh
var _expected_grid : PackedScene
var _submitted_grid : Dictionary

const ROTATION_SPEED = 20
var _rotating : bool = false
var _dragging : bool = false
var _dragging_source : Vector2i
var _subject : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("paint"):
		_rotating = false
		_dragging = true
		_dragging_source = get_viewport().get_mouse_position()
	if Input.is_action_just_released("paint"):
		_dragging = false
	if _rotating:
		rotate_models_up(delta * ROTATION_SPEED)
	if _dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		rotate_models_up((_dragging_source.x - mouse_pos.x) / 10.0)
		_dragging_source.x = mouse_pos.x
		rotate_models_left((_dragging_source.y - mouse_pos.y) / 10.0)
		_dragging_source.y = mouse_pos.y
	if Input.is_action_just_pressed("zoom_in"):
		zoom_in()
	if Input.is_action_just_pressed("zoom_out"):
		zoom_out()

func rotate_models_up(degrees: float):
	expected_marker.rotate_y(deg_to_rad(degrees))
	submitted_marker.rotation = expected_marker.rotation

func rotate_models_left(degrees: float):
	if expected_marker.global_rotation_degrees.x > 85 and degrees > 0:
		return
	if expected_marker.global_rotation_degrees.x < -85 and degrees < 0:
		return
	expected_marker.rotate_object_local(Vector3.MODEL_LEFT, deg_to_rad(degrees))
	expected_marker.global_rotation_degrees.z = 0
	submitted_marker.rotation = expected_marker.rotation

func display_sculptures(grid_min_bounds: Vector3i, grid_max_bounds: Vector3i):
	# expected
	var grid = _expected_grid.instantiate()
	# submitted
	var item : int = 0
	%expectedSubViewport.add_child(grid)
	for i in range(grid_min_bounds.x, grid_max_bounds.x + 1):
		for j in range(grid_min_bounds.y, grid_max_bounds.y + 1):
			for k in range(grid_min_bounds.z, grid_max_bounds.z + 1):
				item = _submitted_grid[str(i) + "," + str(j) + "," + str(k)]
				submitted_grid.set_cell_item(Vector3i(i, j, k), item if item < 0 else item + 1)

func level_complete(original: Mesh, expected: PackedScene, submitted: Dictionary, mark: int, subject: String, default_camera_zoom: float, v_offset: float, grid_min_bounds: Vector3i, grid_max_bounds: Vector3i):
	BackgroundMusic.fade_into("level_complete", 4)
	_original_mesh = original
	_expected_grid = expected
	_submitted_grid = submitted
	display_sculptures(grid_min_bounds, grid_max_bounds)

	expected_camera.fov = default_camera_zoom
	submitted_camera.fov = default_camera_zoom
	expected_camera.v_offset = v_offset
	submitted_camera.v_offset = v_offset
	grade.value = mark
	_subject = subject
	_rotating = true

	if Input.get_connected_joypads().size() > 0:
		next_level_button.grab_focus()
	get_tree().create_timer(1).timeout.connect(enable_next_level_button)
	show()

func zoom_in():
	expected_camera.fov += 3
	if expected_camera.fov > 100:
		expected_camera.fov = 100
	submitted_camera.fov = expected_camera.fov

func zoom_out():
	expected_camera.fov -= 3
	if expected_camera.fov < 1:
		expected_camera.fov = 1
	submitted_camera.fov = expected_camera.fov

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
	var img = submitted_sub_viewport.get_texture().get_image()
	if OS.get_name() == "Web":
		var buffer := img.save_png_to_buffer()
		JavaScriptBridge.download_buffer(buffer, "%s.png" % "export", "image/png")
	else:
		img.save_png("user://export.png")
		OS.shell_open(OS.get_user_data_dir() + "/export.png")
	var url = TWITTER_SHARE_URL + (tr("Look at this beautiful 3d model I carved with the #ScaleItDown game of a %s. Play at https://jynus.itch.io/scale-it-down") % tr(_subject)).uri_encode()
	OS.shell_open(url)
	pass

func _on_share_button_entered() -> void:
	share_button.self_modulate = Color(Color.GRAY)

func _on_share_button_exited() -> void:
	share_button.self_modulate = Color(Color.WHITE)
