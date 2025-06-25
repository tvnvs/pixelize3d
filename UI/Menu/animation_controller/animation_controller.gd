extends TabContainer

signal animation_changed(event: AnimationEvent)

@onready var animation_control_scene: PackedScene = preload("res://UI/Menu/animation_controller/animation_line/animation_line.tscn")
@onready var animation_list_node: VBoxContainer = %AnimationList

var animations: Array[String]

func _ready() -> void:
	if animations != null:
		_on_render_canvas_player_node_animations_changed(animations)

func _on_render_canvas_player_node_animations_changed(new_animation_names:Array[String]) -> void:
	if not is_node_ready():
		animations = new_animation_names
		return
		
	clear_list()
	for animation in new_animation_names:
		var animation_control: AnimationLine = animation_control_scene.instantiate()
		animation_control.animation_name = animation
		animation_control.ready.connect(func():
			animation_control.play_button.button_down.connect(_on_animation_list_play_animation.bind( animation))
			animation_control.test_out_of_bounds_button.button_down.connect(_on_animation_list_test_animation.bind( animation))
		)
		
		animation_list_node.add_child(animation_control)
		animation_list_node.add_child(HSeparator.new())
		


func clear_list() -> void:
	for node in animation_list_node.get_children():
		node.queue_free()

func _on_animation_list_play_animation(animation_name: String):
	animation_changed.emit(AnimationEvent.play(animation_name))

func _on_animation_list_test_animation(animation_name: String):
	animation_changed.emit(AnimationEvent.test(animation_name))
