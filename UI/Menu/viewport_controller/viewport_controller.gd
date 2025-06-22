extends VBoxContainer
class_name ViewportController

signal player_position_changed(_transform: Vector3)
signal player_rotation_changed(_transform: Vector3)
signal player_scale_changed(_transform: Vector3)
signal camera_position_changed(_transform: Vector3)
signal camera_rotation_changed(_transform: Vector3)
@onready var player_postion_node: Vector3Input = %PlayerPosition
@onready var player_rotation_node: Vector3Input = %PlayerRotation
@onready var player_scale_node: Vector3Input = %PlayerScale
@onready var camera_position_node: Vector3Input = %CameraPosition
@onready var camera_rotation_node: Vector3Input = %CameraRotation


func set_player_position(new_transform: Vector3):
	player_postion_node.transform = new_transform


func set_player_rotation_degrees(new_transform: Vector3):
	player_rotation_node.transform = new_transform


func set_player_scale(new_transform: Vector3):
	player_scale_node.transform = new_transform


func set_camera_position(new_transform: Vector3):
	camera_position_node.transform = new_transform


func set_camera_rotation(new_transform: Vector3):
	camera_rotation_node.transform = new_transform


func _on_position_transform_changed(_transform: Vector3) -> void:
	player_position_changed.emit(_transform)


func _on_rotation_transform_changed(_transform: Vector3) -> void:
	player_rotation_changed.emit(_transform)


func _on_scale_transform_changed(_transform: Vector3) -> void:
	player_scale_changed.emit(_transform)


func _on_camera_position_transform_changed(_transform: Vector3) -> void:
	camera_position_changed.emit(_transform)


func _on_camera_rotation_transform_changed(_transform: Vector3) -> void:
	camera_rotation_changed.emit(_transform)


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
