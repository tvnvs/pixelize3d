extends Control
class_name RenderCanvas

signal player_node_transform_changed(new_player_node_transform: TransformProperties)
signal camera_node_transform_changed(new_camera_node_transform: TransformProperties)
signal player_node_animations_changed(new_animation_names: Array[String])


class TransformProperties:
	var position: Vector3
	var rotation_deg: Vector3
	var scale: Vector3


	func _init(position: Vector3, rotation_deg: Vector3, scale: Vector3) -> void:
		self.position = position
		self.rotation_deg = rotation_deg
		self.scale = scale





@export var fps: int = 16

var frames_per_row: int = 25
var state               = 'one'

@onready var after_viewport = $after_effect/after_viewport
@onready var player_viewport = $first_render/Viewport
@onready var player_node: Node3D
@onready var color_shader_node: ColorShader = %ColorShader
@onready var camera_node: Camera3D = %Camera3D
@onready var viewport_texture = player_viewport.get_texture()

var animation_player: AnimationPlayer

func _ready() -> void:
	_update_player_references($first_render/Viewport/Player)
	_emit_player_node_changes()
	_emit_camera_node_changes()

func _update_player_references(new_player_node: Node3D):
	player_node = new_player_node
	animation_player = player_node.find_child("AnimationPlayer")

func render(outpu_dir: String):
	var arr: Array = await get_all_animation_frames()
	print(arr.size())
	var anime_names := arr[1] as Array
	var images      := arr[0] as Array
	for i in anime_names.size():
		var img: Image
		img = images[i]
		var path = outpu_dir + anime_names[i] + ".png"
		img.save_png(path)
		
func get_all_animation_frames():
	var animation_names: Array
	var img_array: Array
	var collector_buffer: Array
	var old_player_transform = player_node.global_transform
	var img_buffer           = []
	for anim in animation_player.get_animation_list():
		animation_player.assigned_animation = anim
		if state == 'all':
			collector_buffer.append_array(await capture_current_animation(animation_player))
		if state == 'one':
			animation_names.append(anim)
			img_buffer.append(await capture_current_animation(animation_player))
		if state == 'eight':
			#render each direction as an array of images and then append it as an array within the image_buffer array
			var eight_buffer: Array
			animation_names.append(anim + "8")
			for i in 8:
				eight_buffer.append_array(await capture_current_animation(animation_player))
				animation_player.seek(0.0)
				player_node.rotation_degrees.y += 45.0
			img_buffer.append(eight_buffer)
			player_node.global_transform = old_player_transform
	if state == 'all':
		animation_names.append("All")
		img_buffer.append(collector_buffer)
	img_array = collect_images(img_buffer, animation_names.size())
	return [img_array, animation_names]


func collect_images(buffer: Array, size: int):
	var images: Array
	print(buffer.size())
	for i in size:
		images.append(concatenate_images(buffer[i]))
	return images


func capture_current_animation(animation_player):
	var image_buffer       = []
	var step               = 1.0/fps
	var animation_length   = animation_player.current_animation_length
	var animation_position = 0

	while animation_position < animation_length:
		animation_player.seek(animation_position, true)
		await RenderingServer.frame_post_draw
		image_buffer.append(capture_viewport())
		animation_position += step

	return image_buffer


func concatenate_images(buffer):
	var frame_size   = player_viewport.size
	var frame_width  = frame_size.x
	var frame_height = frame_size.y
	var nb_of_rows   = int(pow(len(buffer), 0.5)) + 1
	frames_per_row = nb_of_rows
	var concat_img   = Image.create(frame_width * frames_per_row, frame_height * nb_of_rows, false, Image.FORMAT_RGBA8)
	var img_idx: int
	for row_idx in range(nb_of_rows):
		for col_idx in range(frames_per_row):
			img_idx = col_idx + row_idx * frames_per_row
			if img_idx > len(buffer) - 1: break
			var src_rect = Rect2i(Vector2.ZERO, Vector2(frame_width, frame_height))
			var dst      = Vector2i(col_idx*frame_width, row_idx*frame_height)
			concat_img.blit_rect(buffer[img_idx], src_rect, dst)
	return concat_img


func capture_viewport():
	var viewport = after_viewport
	if not color_shader_node.is_visible():
		viewport = player_viewport
	var img = viewport.get_texture().get_image()
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



# Event Emmiting
func _emit_player_node_changes():
	player_node_transform_changed.emit(TransformProperties.new(player_node.position, player_node.rotation_degrees, player_node.scale))
	player_node_animations_changed.emit(animation_player.get_animation_list())

func _emit_camera_node_changes():
	camera_node_transform_changed.emit(TransformProperties.new(camera_node.position, camera_node.rotation_degrees, camera_node.scale))
	
# Event Recieving
func _on_render_options_render_state_changed(new_state: String) -> void:
	state = new_state
	
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
