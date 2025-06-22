extends MarginContainer
class_name AnimationLine

@onready var animation_name_label: Label = %AnimationNameLabel
@onready var play_button: Button = %PlayButton

var animation_name: String = "Undefined"
var play_button_pressed: Callable


func _ready() -> void:
	animation_name_label.text = animation_name
	if play_button_pressed != null:
		play_button.pressed.connect(play_button_pressed)
