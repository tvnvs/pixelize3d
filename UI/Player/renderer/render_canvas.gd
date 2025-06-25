extends Control
class_name RenderCanvas

const MOUSE_BUTTON_MASK_WHEEL_UP: int   = 8
const MOUSE_BUTTON_MASK_WHEEL_DOWN: int = 16
signal player_node_animations_changed(new_animation_names: Array[String])
signal player_node_transform_changed(new_player_node_transform: TransformEvent)
signal camera_node_transform_changed(new_camera_node_transform: TransformEvent)

@onready var shader_viewport: SubViewport = %ShaderViewport
@onready var main_viewport_container: SubViewportContainer = %MainViewportContainer
@onready var color_shader_node: ColorShader = %ColorShader
@onready var main_viewport = %MainViewport
@onready var camera_node: Camera3D = %Camera3D
@onready var player_node: Node3D = %MainViewport/Player
@onready var debug_mesh_node: MeshInstance3D = %DebugMesh
@onready var animation_player: AnimationPlayer = player_node.find_child("AnimationPlayer")
@onready var viewport_texture = main_viewport.get_texture()

var mouse_drag_transform: MouseDragTransform = MouseDragTransform.new()
# AABB
var player_mesh_aabb: AABB
var is_player_aabb_out_of_bounds: bool = true


func _ready() -> void:
	color_shader_node.hide()
	_update_player_references(player_node)
	mouse_drag_transform.node_transforme_ended.connect(_transform_ended)
	update_player_mesh_aabb()


# Render
func _on_render_options_render_start(render_config: RenderConfig) -> void:
	render(render_config)


func render(render_config: RenderConfig):
	debug_mesh_node.hide()
	var viewport: SubViewport = shader_viewport
	if not color_shader_node.is_visible():
		viewport = main_viewport
	var renderer    =  Renderer.new(render_config, viewport, main_viewport_container.animation_player, main_viewport_container.player_node)
	var arr: Array  =  await renderer.get_all_animation_frames()
	var images      := arr[Renderer.IMAGES_INDEX] as Array
	var anime_names := arr[Renderer.ANIMATION_NAME_INDEX] as Array
	#
	for i in anime_names.size():
		var img: Image
		img = images[i]
		var path: String = render_config.build_file_path(anime_names[i], main_viewport_container.player_node.rotation_degrees.y)
		img.save_png(path)
	debug_mesh_node.show()


# Shader 
func _on_material_conntroller_material_changed(_material: ShaderMaterial, debug_draw: float) -> void:
	_material.set_shader_parameter("view", viewport_texture)
	color_shader_node.material = _material
	main_viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED if debug_draw == 0 else Viewport.DEBUG_DRAW_NORMAL_BUFFER


func _on_material_conntroller_color_shader_active(is_active: bool) -> void:
	if is_active:
		color_shader_node.show()
	else:
		color_shader_node.hide()


## AABB
func update_player_mesh_aabb() -> void:
	var player_mesh_instance_3d: MeshInstance3D = player_node.find_children("*", "MeshInstance3D")[0]
	if player_mesh_instance_3d == null:
		return AABB()

	player_mesh_aabb                  = AABBMath.get_precise_aabb(player_mesh_instance_3d)
	var debug_mesh: BoxMesh            = debug_mesh_node.get_mesh()
	var debug_mesh_mat: BaseMaterial3D = debug_mesh_node.get_active_material(0)

	debug_mesh_mat.albedo_color = Color(0, 1, 0, .5)
	if debug_mesh_node.visible:
		debug_mesh_node.global_position = player_mesh_aabb.get_center()
		debug_mesh.size = player_mesh_aabb.size

	var vectors: PackedVector3Array = AABBMath.get_aabb_vertices(player_mesh_aabb)
	debug_mesh_mat.albedo_color = Color(0, 1, 0, .5)

	is_player_aabb_out_of_bounds = false

	for vector: Vector3 in vectors:
		if not _check_point_in_viewport(vector):
			debug_mesh_mat.albedo_color = Color(1, 0, 0, .5)
			is_player_aabb_out_of_bounds = true


func _check_point_in_viewport(point: Vector3) -> bool:
	var viewport_position: Vector2 = camera_node.unproject_position(point)
	if viewport_position.x < 0 or viewport_position.x > main_viewport_container.size.x or viewport_position.y < 0 or viewport_position.y > main_viewport_container.size.y:
		return false
	return true


# Player Transform
func _on_viewport_options_player_transform_changed(_transform: TransformEvent) -> void:
	update_player_transform(_transform)


func update_player_transform(_transform: TransformEvent) -> void:
	player_node.position = _transform.position
	player_node.rotation_degrees = _transform.rotation_deg
	player_node.scale = _transform.scale
	update_player_mesh_aabb()


# Camera Transform
func _on_viewport_options_camera_transform_changed(_transform: TransformEvent) -> void:
	update_camera_transform(_transform)


func update_camera_transform(_transform: TransformEvent) -> void:
	camera_node.position = _transform.position
	camera_node.rotation_degrees = _transform.rotation_deg


# Change Player/Camera transform
func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	elif event.keycode == KEY_SHIFT:
		if event.is_pressed():
			mouse_drag_transform.lock_x = true
		else:
			mouse_drag_transform.lock_x = false
	elif event.keycode == KEY_CTRL:
		if event.is_pressed():
			mouse_drag_transform.lock_y = true
		else:
			mouse_drag_transform.lock_y = false

	mouse_drag_transform.check_for_postion_reset(Input.is_key_pressed(KEY_ALT))


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion:
		mouse_drag_transform.handle_mouse_motion_event(event)


func _handle_mouse_button_input(event: InputEventMouseButton) -> void:
	var node: Node3D         = player_node
	var is_mouse_wheel: bool = event.button_mask == MOUSE_BUTTON_MASK_WHEEL_UP or event.button_mask == MOUSE_BUTTON_MASK_WHEEL_DOWN
	if is_mouse_wheel:
		mouse_drag_transform.handle_one_shot_scale_node(node, 1 if event.button_mask == MOUSE_BUTTON_MASK_WHEEL_UP else -1)
	else:
		if event.pressed:
			var edit_type: Enums.ViewportEditType
			match event.button_mask:
				MOUSE_BUTTON_MASK_LEFT: edit_type=Enums.ViewportEditType.POSITION
				MOUSE_BUTTON_MASK_RIGHT: edit_type=Enums.ViewportEditType.ROTATION
				MOUSE_BUTTON_WHEEL_UP or MOUSE_BUTTON_WHEEL_DOWN: edit_type=Enums.ViewportEditType.SCALE
				MOUSE_BUTTON_MASK_MIDDLE:
					edit_type=Enums.ViewportEditType.ROTATION
					node=camera_node
			mouse_drag_transform.enter_edit_mode(node, edit_type)
		elif not event.pressed:
			mouse_drag_transform.exit_edit_mode()


func _transform_ended(node: Node3D):
	var event = TransformEvent.new(node.position, node.rotation_degrees, node.scale)

	if node == player_node:
		player_node_transform_changed.emit(event)
	if node == camera_node:
		camera_node_transform_changed.emit(event)
	update_player_mesh_aabb()


# Player Animation
func _on_animation_controller_animation_changed(event: AnimationEvent) -> void:
	match event.action:
		Enums.AnimationEventAction.PLAY: play_animation(event.animation_name)
		Enums.AnimationEventAction.TEST: test_animation(event.animation_name)


func play_animation(animation_name: String)-> void:
	animation_player.play(animation_name)


func test_animation(animation_name: String)-> void:
	animation_player.assigned_animation = animation_name
	var step: float               = 1.0/60
	var animation_length: float   = animation_player.current_animation_length
	var animation_position: float = 0

	while animation_position < animation_length:
		animation_player.seek(animation_position, true)
		update_player_mesh_aabb()
		if is_player_aabb_out_of_bounds:
			return
		animation_position += step
		await get_tree().create_timer(step).timeout


## Player Model
func load_new_player_model(new_model_path: String) -> Node3D:
	if new_model_path.ends_with(".gltf") or new_model_path.ends_with(".glb"):
		var gltf_state: GLTFState       = GLTFState.new()
		var gltf_document: GLTFDocument = GLTFDocument.new()
		gltf_document.append_from_file(new_model_path, gltf_state)
		var node: Node = gltf_document.generate_scene(gltf_state)

		node.transform = player_node.transform

		var node_parent: Node = player_node.get_parent()
		player_node.name = "OldPlayer"
		player_node.queue_free()

		node_parent.add_child(node)
		node.set_owner(node_parent)
		node.name = "Player"

		_update_player_references(node)
		return node
	return null


func _update_player_references(new_player_node: Node3D):
	player_node = new_player_node
	animation_player = player_node.find_child("AnimationPlayer")
	player_node_transform_changed.emit(TransformEvent.new(player_node.position, player_node.rotation_degrees, player_node.scale))
	player_node_animations_changed.emit(animation_player.get_animation_list())
