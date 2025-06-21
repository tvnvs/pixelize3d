extends VBoxContainer
class_name ViewportController

signal player_position_changed(_transform: Vector3)
signal player_rotation_changed(_transform: Vector3)
signal player_scale_changed(_transform: Vector3)


@onready var player_postion_node: Vector3Input = $PlayerPosition
@onready var player_rotation_node: Vector3Input = $PlayerRotation
@onready var player_scale_node: Vector3Input = $PlayerScale


func set_player_position(new_transform:Vector3):
	player_postion_node.transform = new_transform
	
func set_player_rotation_degrees(new_transform:Vector3):
	player_rotation_node.transform = new_transform
	
func set_player_scale(new_transform:Vector3):
	player_scale_node.transform = new_transform

func _on_position_transform_changed(_transform:Vector3) -> void:
	player_position_changed.emit(_transform)


func _on_rotation_transform_changed(_transform:Vector3) -> void:
	player_rotation_changed.emit(_transform)


func _on_scale_transform_changed(_transform:Vector3) -> void:
	player_scale_changed.emit(_transform)
