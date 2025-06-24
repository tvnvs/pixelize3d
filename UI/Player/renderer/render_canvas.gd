extends Control
class_name RenderCanvas

signal player_node_transform_changed(new_player_node_transform: TransformProperties)
signal camera_node_transform_changed(new_camera_node_transform: TransformProperties)
signal player_node_animations_changed(new_animation_names: Array[String])
const MOUSE_BUTTON_MASK_WHEEL_UP: int           = 8
const MOUSE_BUTTON_MASK_WHEEL_DOWN: int         = 16
const FILE_NAME_ANGLE_CONST      = "_angle_"
const FILE_NAME_DEFAULT_PLACEHOLDER      = "{{default}}"
const FILE_NAME_ANIMATION_NAME_PLACEHOLDER      = "{{animation}}"
const FILE_NAME_PLAYER_ROTATION_DEG_PLACEHOLDER = "{{p_angle_deg}}"
const FILE_NAME_PLAYER_ROTATION_DEG_INT_PLACEHOLDER = "{{p_angle_deg_int}}"





class TransformProperties:
	var position: Vector3
	var rotation_deg: Vector3
	var scale: Vector3


	func _init(position: Vector3, rotation_deg: Vector3, scale: Vector3) -> void:
		self.position = position
		self.rotation_deg = rotation_deg
		self.scale = scale


enum ViewportEditType{
	PLAYER_POSITION,
	PLAYER_ROTATION,
	PLAYER_SCALE,
	CAMERA
}
enum RenderMode{
	ALL,
	ONE,
	MULTIPLE_ANGLES,
}
@export var fps: int = 16

var frames_per_row: int = 25
var state: RenderMode   = RenderMode.ONE

@onready var after_viewport = $after_effect/after_viewport
@onready var player_viewport = $first_render/Viewport
@onready var player_node: Node3D
@onready var color_shader_node: ColorShader = %ColorShader
@onready var camera_node: Camera3D = %Camera3D
@onready var viewport_texture = player_viewport.get_texture()

var animation_player: AnimationPlayer
var export_file_name_pattern: String = ""
var export_rotation_angles: int      = 1
## Edit Viewport Vars
var viewport_edit_mode: bool = false
var viewport_edit_type: ViewportEditType
var viewport_lock_x: bool    = false
var viewport_lock_y: bool    = false
var viewport_reset_pos: bool = false
var viewport_initial_position: Vector3
var viewport_position_restore: Vector3
var single_file_animation: bool = true


func _ready() -> void:
	_update_player_references($first_render/Viewport/Player)
	_emit_player_node_changes()
	_emit_camera_node_changes()


func _update_player_references(new_player_node: Node3D):
	player_node = new_player_node
	animation_player = player_node.find_child("AnimationPlayer")


func render(outpu_dir: String):
	var arr: Array = await get_all_animation_frames()
	var images      := arr[0] as Array
	var anime_names := arr[1] as Array
	for i in anime_names.size():
		var img: Image
		img = images[i]
		var path = outpu_dir + _build_file_name(anime_names[i])
		img.save_png(path)


func _build_file_name(animation_gen_name: String) -> String:
	var file_name = animation_gen_name+".png"
	if animation_gen_name == null or animation_gen_name.is_empty():
		return file_name
	var animation_name: String = animation_gen_name
	var rotation_deg: float = player_node.rotation_degrees.y
	
	if animation_name.contains(FILE_NAME_ANGLE_CONST):
		var split: PackedStringArray = animation_name.split(FILE_NAME_ANGLE_CONST)
		animation_name = split[0]
		rotation_deg = float(split[1])
	file_name = export_file_name_pattern
	if file_name.contains(FILE_NAME_DEFAULT_PLACEHOLDER):
		file_name = file_name.replacen(FILE_NAME_DEFAULT_PLACEHOLDER, animation_gen_name)
	if file_name.contains(FILE_NAME_ANIMATION_NAME_PLACEHOLDER):
		file_name = file_name.replacen(FILE_NAME_ANIMATION_NAME_PLACEHOLDER, animation_name)
	if file_name.contains(FILE_NAME_PLAYER_ROTATION_DEG_PLACEHOLDER):
		file_name = file_name.replacen(FILE_NAME_PLAYER_ROTATION_DEG_PLACEHOLDER, "%.2f" % rotation_deg)
	if file_name.contains(FILE_NAME_PLAYER_ROTATION_DEG_INT_PLACEHOLDER):
		file_name = file_name.replacen(FILE_NAME_PLAYER_ROTATION_DEG_INT_PLACEHOLDER, "%03d" % int(floor(rotation_deg)))

	return file_name



#func get_all_animation_frames():
#	var animation_names: Array
#	var img_array: Array
#	var collector_buffer: Array
#	var old_player_transform: Transform3D = player_node.global_transform
#	var img_buffer: Array[Array]           = []
#	for anim in animation_player.get_animation_list():
#		animation_player.assigned_animation = anim
#		if state == RenderMode.ALL:
#			collector_buffer.append_array(await capture_current_animation())
#		if state == RenderMode.ONE:
#			animation_names.append(anim)
#			img_buffer.append(await capture_current_animation())
#		if state == RenderMode.MULTIPLE_ANGLES:
#			#render each direction as an array of images and then append it as an array within the image_buffer array
#			var eight_buffer: Array
#			animation_names.append(anim + "8")
#			for i in 8:
#				eight_buffer.append_array(await capture_current_animation())
#				animation_player.seek(0.0)
#				player_node.rotation_degrees.y += 45.0
#			img_buffer.append(eight_buffer)
#			player_node.global_transform = old_player_transform
#	if state == RenderMode.ALL:
#		animation_names.append("All")
#		img_buffer.append(collector_buffer)
#	img_array = collect_images(img_buffer, animation_names.size())
#	return [img_array, animation_names]

func get_all_animation_frames()-> Array:
	var animation_names: Array[String]
	var img_array: Array[Image]
	var collector_buffer: Array[Image]
	var img_buffer: Array[Array]      = []
	for anim in animation_player.get_animation_list():
		animation_player.assigned_animation = anim
		if state == RenderMode.ALL:
			collector_buffer.append_array(await capture_current_animation())
		elif state == RenderMode.ONE:
			animation_names.append(anim)
			img_buffer.append(await capture_current_animation())
		elif state == RenderMode.MULTIPLE_ANGLES:
			#render each direction as an array of images and then append it as an array within the image_buffer array
			var angle: float = 360.0 / export_rotation_angles
			var old_player_transform: Transform3D = player_node.global_transform
			var single_file_buffer: Array[Image]
			player_node.rotation_degrees.y = 0
			if single_file_animation:
				animation_names.append(anim)
			for i in export_rotation_angles:
				var image_array: Array[Image] = await capture_current_animation()
				if single_file_animation:
					single_file_buffer.append_array(image_array)
				else:
					animation_names.append("%s%s%.2f" % [anim, FILE_NAME_ANGLE_CONST, player_node.rotation_degrees.y])
					img_buffer.append(image_array)
				animation_player.seek(0.0)
				player_node.rotation_degrees.y += angle

			if single_file_animation:
				img_buffer.append(single_file_buffer)
			player_node.global_transform = old_player_transform
	if state == RenderMode.ALL:
		animation_names.append("All")
		img_buffer.append(collector_buffer)
	img_array = collect_images(img_buffer, animation_names.size())
	return [img_array, animation_names]


func collect_images(buffer: Array[Array], total_animations: int) -> Array[Image]:
	var images: Array[Image]
	for i in total_animations:
		images.append(concatenate_images(buffer[i]))
	return images


func capture_current_animation() -> Array[Image]:
	var image_buffer: Array[Image] = []
	var step: float                = 1.0/fps
	var animation_length: float    = animation_player.current_animation_length
	var animation_position: float  = 0

	while animation_position < animation_length:
		animation_player.seek(animation_position, true)
		await RenderingServer.frame_post_draw
		image_buffer.append(capture_viewport())
		animation_position += step

	return image_buffer


func concatenate_images(buffer: Array[Image]) -> Image:
	var frame_size        = player_viewport.size
	var frame_width       = frame_size.x
	var frame_height      = frame_size.y
	var nb_of_rows: int   = int(pow(len(buffer), 0.5)) + 1
	frames_per_row = nb_of_rows
	var concat_img: Image = Image.create(frame_width * frames_per_row, frame_height * nb_of_rows, false, Image.FORMAT_RGBA8)
	var img_idx: int
	for row_idx in range(nb_of_rows):
		for col_idx in range(frames_per_row):
			img_idx = col_idx + row_idx * frames_per_row
			if img_idx > len(buffer) - 1: break
			var src_rect: Rect2i = Rect2i(Vector2.ZERO, Vector2(frame_width, frame_height))
			var dst: Vector2i    = Vector2i(col_idx*frame_width, row_idx*frame_height)
			concat_img.blit_rect(buffer[img_idx], src_rect, dst)
	return concat_img


func capture_viewport() -> Image:
	var viewport = after_viewport
	if not color_shader_node.is_visible():
		viewport = player_viewport
	var img: Image = viewport.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	return img


func load_new_player_model(new_model_path: String) -> Node3D:
	if new_model_path.ends_with(".gltf") or new_model_path.ends_with(".glb"):
		var state    = GLTFState.new()
		var importer = GLTFDocument.new()
		importer.append_from_file(new_model_path, state)
		var node = importer.generate_scene(state)

		node.transform = player_node.transform

		var node_parent = player_node.get_parent()
		player_node.name = "OldPlayer"
		player_node.queue_free()

		node_parent.add_child(node)
		node.set_owner(node_parent)
		node.name = "Player"

		_update_player_references(node)
		_emit_player_node_changes()
		return node
	return null


func play_animation(animation_name: String):
	animation_player.play(animation_name)


# Event Emmiting
func _emit_player_node_changes():
	player_node_transform_changed.emit(TransformProperties.new(player_node.position, player_node.rotation_degrees, player_node.scale))
	player_node_animations_changed.emit(animation_player.get_animation_list())


func _emit_camera_node_changes():
	camera_node_transform_changed.emit(TransformProperties.new(camera_node.position, camera_node.rotation_degrees, camera_node.scale))


# Edit Viewport Functions
func _enter_edit_mode(button_mask: int, capture_mouse: bool = true):
	viewport_edit_mode = true
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	match button_mask:
		MOUSE_BUTTON_MASK_LEFT: viewport_edit_type=ViewportEditType.PLAYER_POSITION
		MOUSE_BUTTON_MASK_RIGHT: viewport_edit_type=ViewportEditType.PLAYER_ROTATION
		MOUSE_BUTTON_WHEEL_UP or MOUSE_BUTTON_WHEEL_DOWN: viewport_edit_type=ViewportEditType.PLAYER_SCALE
		MOUSE_BUTTON_MASK_MIDDLE: viewport_edit_type=ViewportEditType.CAMERA

	if viewport_edit_type == ViewportEditType.PLAYER_POSITION:
		viewport_initial_position = Vector3(player_node.position)
	elif viewport_edit_type == ViewportEditType.PLAYER_ROTATION:
		viewport_initial_position = Vector3(player_node.rotation)
	elif viewport_edit_type == ViewportEditType.PLAYER_SCALE:
		viewport_initial_position = Vector3(player_node.scale)
	elif viewport_edit_type == ViewportEditType.CAMERA:
		viewport_initial_position = Vector3(camera_node.position)

	print("Enter Edit Mode(%d)" % viewport_edit_type)


func _exit_edit_mode():
	print("Exit Edit Mode(%d)" % viewport_edit_type)
	viewport_edit_mode = false

	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	viewport_initial_position = Vector3.ZERO
	_emit_player_node_changes()
	_emit_camera_node_changes()


func _edit_rest_player_position():
	if viewport_edit_type == ViewportEditType.PLAYER_POSITION:
		viewport_position_restore = Vector3(player_node.position)
		player_node.position = viewport_initial_position
	elif viewport_edit_type == ViewportEditType.PLAYER_ROTATION:
		viewport_position_restore = Vector3(player_node.rotation)
		player_node.rotation = viewport_initial_position
	elif viewport_edit_type == ViewportEditType.PLAYER_SCALE:
		viewport_position_restore = Vector3(player_node.rotation)
		player_node.scale = viewport_initial_position
	elif viewport_edit_type == ViewportEditType.CAMERA:
		viewport_position_restore = Vector3(camera_node.position)
		camera_node.position = viewport_initial_position


func _edit_restore_player_position():
	if viewport_edit_type == ViewportEditType.PLAYER_POSITION:
		player_node.position = viewport_position_restore
	elif viewport_edit_type == ViewportEditType.PLAYER_ROTATION:
		player_node.rotation = viewport_position_restore
	elif viewport_edit_type == ViewportEditType.PLAYER_SCALE:
		player_node.scale = viewport_position_restore
	elif viewport_edit_type == ViewportEditType.CAMERA:
		camera_node.position = viewport_position_restore


func _check_for_postion_lock():
	var is_x_or_y_lock_on   = viewport_lock_x or viewport_lock_y
	var is_lock_key_pressed = Input.is_key_pressed(KEY_ALT)

	if is_x_or_y_lock_on and is_lock_key_pressed and not viewport_reset_pos:
		viewport_reset_pos = true
		_edit_rest_player_position()
	elif not is_lock_key_pressed and viewport_reset_pos:
		viewport_reset_pos = false
		if viewport_edit_mode:
			_edit_restore_player_position()


# Event Handling (Internal)


func _on_color_shader_gui_input(event: InputEvent) -> void:
	_on_gui_input(event)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var is_mouse_wheel: bool = event.button_mask == MOUSE_BUTTON_MASK_WHEEL_UP or event.button_mask == MOUSE_BUTTON_MASK_WHEEL_DOWN
		if is_mouse_wheel:
			_handle_scale_player(event)
		else:
			_handle_mouse_button_event(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion_event(event)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if event.keycode == KEY_ESCAPE and viewport_edit_mode:
		_exit_edit_mode()
	elif event.keycode == KEY_SHIFT:
		if event.is_pressed():
			viewport_lock_x = true
		else:
			viewport_lock_x = false
	elif event.keycode == KEY_CTRL:
		if event.is_pressed():
			viewport_lock_y = true
		else:
			viewport_lock_y = false

	_check_for_postion_lock()


func _handle_scale_player(event: InputEventMouse) -> void:
	var speed: float   = 0.02
	var direction: int = 1 if event.button_mask == MOUSE_BUTTON_MASK_WHEEL_UP else -1
	_enter_edit_mode(event.button_mask, false)
	player_node.scale += Vector3(1, 1, 1)  * speed * direction
	_exit_edit_mode()


func _handle_mouse_button_event(event: InputEventMouseButton):
	if event.pressed:
		_enter_edit_mode(event.get_button_mask())
	elif not event.pressed:
		_exit_edit_mode()


func _handle_mouse_motion_event(event: InputEventMouseMotion):
	if not viewport_edit_mode:
		return
	var direction: Vector2 = event.relative.normalized()
	var speed: float       = 0.02
	var x: float           = 0.0 if viewport_lock_x else direction.x
	var y: float           = 0.0 if viewport_lock_y else -direction.y

	var move_vector: Vector3 = Vector3(x, y, 0) * speed
	print(move_vector)
	if viewport_edit_type == ViewportEditType.PLAYER_POSITION:
		player_node.position += move_vector
	elif viewport_edit_type == ViewportEditType.PLAYER_ROTATION:
		player_node.rotation += Vector3(move_vector.y, move_vector.x, 0)
	elif viewport_edit_type == ViewportEditType.CAMERA:
		var camera_angle_x_deg: float     = camera_node.rotation_degrees.x
		var camera_angle_y_deg: float     = camera_node.rotation_degrees.y
		var new_camera_angle_x_deg: float = clamp(camera_angle_x_deg + (1 * y), -89, 89)
		var new_camera_angle_y_deg: float = clamp(camera_angle_y_deg + (1 * x), -89, 89)
		#		var new_camera_angle_y_deg: float = 5.5

		var camera_height: float   = camera_node.position.y
		var camera_distance: float = camera_node.position.z

		var hipotenuse: float    = camera_distance / cos(deg_to_rad(new_camera_angle_x_deg))
		var new_value: float     = sqrt(hipotenuse*hipotenuse - camera_distance*camera_distance)
		var player_height: float = 0

		camera_node.rotation_degrees.x = new_camera_angle_x_deg
		camera_node.position.y = (new_value if new_camera_angle_x_deg <0 else -new_value) + player_height
		camera_height = new_value


#		camera_node.look_at(player_node.position, rot)


# Event Handling (External)
func _on_render_options_render_state_changed(new_state: RenderMode, new_export_rotation_angles: int) -> void:
	state = new_state
	export_rotation_angles = new_export_rotation_angles


func _on_viewport_options_player_transform_changed(_transform: TransformProperties) -> void:
	player_node.position = _transform.position
	player_node.rotation_degrees = _transform.rotation_deg
	player_node.scale = _transform.scale


func _on_viewport_options_camera_transform_changed(_transform: TransformProperties) -> void:
	camera_node.position = _transform.position
	camera_node.rotation_degrees = _transform.rotation_deg


func _on_material_conntroller_material_changed(_material: ShaderMaterial, debug_draw: float) -> void:
	_material.set_shader_parameter("view", viewport_texture)
	color_shader_node.material = _material
	player_viewport.debug_draw = debug_draw


func _on_material_conntroller_color_shader_active(is_active: bool) -> void:
	if is_active:
		color_shader_node.show()
	else:
		color_shader_node.hide()


func _on_render_options_render_start(output_dir: String) -> void:
	render(output_dir)


func _on_animation_controller_play_animation(animation_name: String) -> void:
	play_animation(animation_name)


func _on_render_controller_render_file_name_pattern_changed(new_file_name_pattern: String) -> void:
	export_file_name_pattern = new_file_name_pattern


func _on_render_controller_render_single_file_animation_changed(new_single_file_animation:bool) -> void:
	single_file_animation = new_single_file_animation
