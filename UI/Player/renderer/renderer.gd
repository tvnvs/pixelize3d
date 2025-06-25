class_name Renderer

const IMAGES_INDEX: int         = 0
const ANIMATION_NAME_INDEX: int = 1
var viewport: SubViewport
var animation_player: AnimationPlayer
var player_node: Node3D
var state: Enums.RenderMode     = Enums.RenderMode.ONE
var export_rotation_angles: int = 1
var single_file_animation: bool = true
var fps: int                    = 16
var frames_per_row: int         = 25

@warning_ignore("shadowed_variable")
func _init(render_config: RenderConfig, viewport: SubViewport, animation_player: AnimationPlayer, player_node: Node3D):
	state = render_config.state
	export_rotation_angles = render_config.export_rotation_angles
	single_file_animation = render_config.single_file_animation
	fps = render_config.fps
	frames_per_row = render_config.frames_per_row
	self.viewport = viewport
	self.animation_player = animation_player
	self.player_node = player_node


func get_all_animation_frames()-> Array:
	var animation_names: Array[String]
	var img_array: Array[Image]
	var collector_buffer: Array[Image]
	var img_buffer: Array[Array] = []

	for anim in animation_player.get_animation_list():
		animation_player.assigned_animation = anim
		if state == Enums.RenderMode.ALL:
			collector_buffer.append_array(await capture_current_animation())
		elif state == Enums.RenderMode.ONE:
			animation_names.append(anim)
			img_buffer.append(await capture_current_animation())
		elif state == Enums.RenderMode.MULTIPLE_ANGLES:
			#render each direction as an array of images and then append it as an array within the image_buffer array
			var angle: float                      = 360.0 / export_rotation_angles
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
					animation_names.append("%s%s%.2f" % [anim, RenderConfig.FILE_NAME_ANGLE_CONST, player_node.rotation_degrees.y])
					img_buffer.append(image_array)
				animation_player.seek(0.0)
				player_node.rotation_degrees.y += angle

			if single_file_animation:
				img_buffer.append(single_file_buffer)
			player_node.global_transform = old_player_transform
	if state == Enums.RenderMode.ALL:
		animation_names.append("All")
		img_buffer.append(collector_buffer)
	img_array = collect_images(img_buffer, animation_names.size())
	return [img_array, animation_names]


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


func capture_viewport() -> Image:
	var img: Image = viewport.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	return img


func collect_images(buffer: Array[Array], total_animations: int) -> Array[Image]:
	var images: Array[Image]
	for i in total_animations:
		images.append(concatenate_images(buffer[i]))
	return images


func concatenate_images(buffer: Array[Image]) -> Image:
	var frame_size: Vector2i = viewport.size
	var frame_width: int     = frame_size.x
	var frame_height: int    = frame_size.y
	var nb_of_rows: int      = int(pow(len(buffer), 0.5)) + 1
	var frames_row: int      = frames_per_row

	if frames_row <= 0:
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
