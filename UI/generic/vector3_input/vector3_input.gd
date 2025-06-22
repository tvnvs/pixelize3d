extends Control
class_name Vector3Input

signal transformChanged(_transform: Vector3)
@export var transformName:String = "undefined"

var transform: Vector3 = Vector3.ZERO : set = _set_transform, get = _get_transform
@onready var transform_x: LineEdit = %ScaleX
@onready var transform_y: LineEdit = %ScaleY
@onready var transform_z: LineEdit = %ScaleZ
@onready var vector_label: Label = %VectorLabel

func _ready():
	vector_label.text = transformName

func _set_transform(value):
	transform = value
	
	transform_x.text = str(value.x)
	transform_y.text = str(value.y)
	transform_z.text = str(value.z)

func _get_transform():
	return transform

func _send_signal_changed():
	transformChanged.emit(transform)
	
func _on_scale_x_text_submitted(new_text):
	transform.x = float(new_text)
	transform_x.text = new_text
	_send_signal_changed()

func _on_scale_y_text_submitted(new_text):
	transform.y = float(new_text)
	transform_y.text = new_text
	_send_signal_changed()

func _on_scale_z_text_submitted(new_text):
	transform.z = float(new_text)
	transform_z.text = new_text
	_send_signal_changed()


