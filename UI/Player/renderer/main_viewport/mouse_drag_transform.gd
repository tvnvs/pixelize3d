class_name MouseDragTransform

signal node_transforme_ended(node: Node3D)


var editing_node: Node3D                = null
var edit_type: Enums.ViewportEditType
var initial_transform: Vector3

var position_restore: Vector3
var reset_pos: bool = false

var translation_speed: float = 0.02
var camera_rotation_speed: float = 1

var is_editting: bool: get=_is_editting, set=_none

var lock_x: bool : get = _get_lock_x, set = _set_lock_x
var lock_y: bool : get = _get_lock_y, set = _set_lock_y
var _lock_x: bool   = false
var _lock_y: bool   = false

# Getters and setters
func _is_editting() -> bool:
	return editing_node != null
func _none(_val: Variant) -> void:
	pass

func _get_lock_x() -> bool:
	return _lock_x
func _set_lock_x(lock: bool) -> void:
	_lock_x = lock
#	_check_for_postion_lock()
func _get_lock_y() -> bool:
	return _lock_y
func _set_lock_y(lock: bool) -> void:
	_lock_y = lock
#	_check_for_postion_lock()


func check_for_postion_reset(is_lock_key_pressed: bool):
	var is_x_or_y_lock_on: bool   = _lock_x or _lock_y

	if is_x_or_y_lock_on and is_lock_key_pressed and not reset_pos:
		reset_pos = true
		node_to_initial_transform()
	elif not is_lock_key_pressed and reset_pos:
		reset_pos = false
		if is_editting:
			restore_node_transform()

func restore_node_transform():
	if edit_type == Enums.ViewportEditType.POSITION:
		editing_node.position = position_restore
	elif edit_type == Enums.ViewportEditType.ROTATION:
		editing_node.rotation = position_restore
	elif edit_type == Enums.ViewportEditType.SCALE:
		editing_node.scale = position_restore

func node_to_initial_transform():
	if edit_type == Enums.ViewportEditType.POSITION:
		position_restore = Vector3(editing_node.position)
		editing_node.position = initial_transform
	elif edit_type == Enums.ViewportEditType.ROTATION:
		position_restore = Vector3(editing_node.rotation)
		editing_node.rotation = initial_transform
	elif edit_type == Enums.ViewportEditType.SCALE:
		position_restore = Vector3(editing_node.rotation)
		editing_node.scale = initial_transform


func enter_edit_mode(node: Node3D, type: Enums.ViewportEditType, capture_mouse: bool = true):
	if is_editting:
		return
	editing_node = node
	edit_type = type
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if edit_type == Enums.ViewportEditType.POSITION:
		initial_transform = Vector3(node.position)
	elif edit_type == Enums.ViewportEditType.ROTATION:
		initial_transform = Vector3(node.rotation)
	elif edit_type == Enums.ViewportEditType.SCALE:
		initial_transform = Vector3(node.scale)
		
	print("Entering editing node %s. Edit type: %d" % [editing_node.name, edit_type])


func exit_edit_mode() -> void:
	if not is_editting:
		return
	var node = editing_node
	print("Exiting node %s. Edit type: %d" % [editing_node.name, edit_type])
	editing_node = null

	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	initial_transform = Vector3.ZERO
	node_transforme_ended.emit(node)
	
func handle_one_shot_scale_node(node: Node3D, direction: int) -> void:
	var speed: float   = 0.02
	enter_edit_mode(node, Enums.ViewportEditType.SCALE, false)
	node.scale += Vector3(1, 1, 1)  * speed * direction
	exit_edit_mode()

func handle_mouse_motion_event(event: InputEventMouseMotion) -> void:
	if editing_node == null:
		return
	var direction: Vector2 = event.relative.normalized()
	var x: float           = 0.0 if _lock_x else direction.x
	var y: float           = 0.0 if _lock_y else -direction.y

	var move_vector: Vector3 = Vector3(x, y, 0) 
	if edit_type == Enums.ViewportEditType.POSITION:
		editing_node.position += move_vector * translation_speed
	elif edit_type == Enums.ViewportEditType.ROTATION:
		if editing_node is Camera3D:
			_handle_camera_rotation(move_vector * camera_rotation_speed)
		else:
			editing_node.rotation += Vector3(move_vector.y, move_vector.x, 0) * translation_speed

			
func _handle_camera_rotation(move_vector: Vector3) -> void:
	var camera_angle_x_deg: float     = editing_node.rotation_degrees.x
	var new_camera_angle_x_deg: float = clamp(camera_angle_x_deg + (1 * move_vector.y), -89, 89)
	var new_value: float              = calculate_camera_hight_for_angle( new_camera_angle_x_deg)
	editing_node.rotation_degrees.x = new_camera_angle_x_deg
	editing_node.position.y = (new_value if new_camera_angle_x_deg <0 else -new_value)


func calculate_camera_hight_for_angle(angle: float) -> float:
	var camera_distance: float = editing_node.position.z

	var hipotenuse: float = camera_distance / cos(deg_to_rad(angle))
	var new_value: float  = sqrt(hipotenuse*hipotenuse - camera_distance*camera_distance)
	return new_value
