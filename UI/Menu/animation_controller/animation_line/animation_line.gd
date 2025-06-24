extends MarginContainer
class_name AnimationLine

@onready var animation_name_label: Label = %AnimationNameLabel
@onready var play_button: Button = %PlayButton
@onready var test_out_of_bounds_button: Button = %TestOutOfBoundsButton

var animation_name: String = "Undefined"


func _ready() -> void:
	animation_name_label.text = animation_name
