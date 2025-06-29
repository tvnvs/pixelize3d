class_name AnimationInfo

var animation_name: String
var is_test: bool


@warning_ignore("shadowed_variable")
func _init(animation_name: String, is_test: bool) -> void:
	self.animation_name = animation_name
	self.is_test = is_test

func equals(animation: AnimationInfo) -> bool:
	if animation == null:
		return false
	return self.animation_name == animation.animation_name and self.is_test == animation.is_test
