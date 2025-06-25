class_name TransformEvent

var position: Vector3
var rotation_deg: Vector3
var scale: Vector3


@warning_ignore("SHADOWED_VARIABLE")
func _init(position: Vector3, rotation_deg: Vector3, scale: Vector3):
	self.position = position
	self.rotation_deg = rotation_deg
	self.scale = scale

