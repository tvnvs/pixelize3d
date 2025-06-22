extends VBoxContainer
class_name ViewportController

signal player_transform_changed(_transform: RenderCanvas.TransformProperties)
signal camera_transform_changed(_transform: RenderCanvas.TransformProperties)


@onready var player_position_node: Vector3Input = %PlayerPosition
@onready var player_rotation_node: Vector3Input = %PlayerRotation
@onready var player_scale_node: Vector3Input = %PlayerScale
@onready var camera_position_node: Vector3Input = %CameraPosition
@onready var camera_rotation_node: Vector3Input = %CameraRotation

var starting_player_node_transform: RenderCanvas.TransformProperties = null
var starting_camera_node_transform: RenderCanvas.TransformProperties = null

func _ready() -> void:
	if starting_player_node_transform != null:
		_on_render_canvas_player_node_transform_changed(starting_player_node_transform)
	if starting_camera_node_transform != null:
		_on_render_canvas_camera_node_transform_changed(starting_camera_node_transform)

# Event Emiting
func _emit_player_transform_changed() -> void:
	player_transform_changed.emit(RenderCanvas.TransformProperties.new(player_position_node.transform, player_rotation_node.transform, player_scale_node.transform))


func _emit_camera_transform_changed() -> void:
	camera_transform_changed.emit(RenderCanvas.TransformProperties.new(camera_position_node.transform, camera_rotation_node.transform, Vector3.ONE))

# Event Recieving
func _on_front_view_preset_button_down() -> void:
	camera_position_node.transform = Vector3(0, 0.511, 10)
	camera_rotation_node.transform = Vector3(0, 0, 0)

	camera_position_node._send_signal_changed()
	camera_rotation_node._send_signal_changed()


func _on_isometric_preset_35_button_down() -> void:
	camera_position_node.transform = Vector3(0, 7.662, 10)
	camera_rotation_node.transform = Vector3(-35.564, 0, 0)

	camera_position_node._send_signal_changed()
	camera_rotation_node._send_signal_changed()


func _on_isometric_preset_45_button_down() -> void:
	camera_position_node.transform = Vector3(0, 10.379, 10)
	camera_rotation_node.transform = Vector3(-45, 0, 0)

	camera_position_node._send_signal_changed()
	camera_rotation_node._send_signal_changed()


func _on_render_canvas_player_node_transform_changed(new_player_node_properties:RenderCanvas.TransformProperties) -> void:
	if not is_node_ready():
		starting_player_node_transform = new_player_node_properties
		return
	player_position_node.transform = new_player_node_properties.position
	player_rotation_node.transform = new_player_node_properties.rotation_deg
	player_scale_node.transform = new_player_node_properties.scale

	
func _on_render_canvas_camera_node_transform_changed(new_camera_node_properties:RenderCanvas.TransformProperties) -> void:
	if not is_node_ready():
		starting_camera_node_transform = new_camera_node_properties
		return
	camera_position_node.transform = new_camera_node_properties.position
	camera_rotation_node.transform = new_camera_node_properties.rotation_deg

# Event Forwarding
func _on_position_transform_changed(_transform: Vector3) -> void:
	_emit_player_transform_changed()


func _on_rotation_transform_changed(_transform: Vector3) -> void:
	_emit_player_transform_changed()


func _on_scale_transform_changed(_transform: Vector3) -> void:
	_emit_player_transform_changed()


func _on_camera_position_transform_changed(_transform: Vector3) -> void:
	_emit_camera_transform_changed()


func _on_camera_rotation_transform_changed(_transform: Vector3) -> void:
	_emit_camera_transform_changed()
