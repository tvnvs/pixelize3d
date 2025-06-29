extends TabContainer

signal animation_changed(event: AnimationEvent)
signal animation_play_mode_changed(event: Enums.AnimationPlayMode)

@onready var animation_control_scene: PackedScene = preload("res://UI/Menu/animation_controller/animation_line/animation_line.tscn")
@onready var animation_list_node: VBoxContainer = %AnimationList
@onready var animation_play_mode_node: OptionButton = %AnimationPlayMode

var animations: Array[String]

func _ready() -> void:
	animation_play_mode_changed.emit(animation_play_mode_node.selected)
	if animations != null:
		_on_render_canvas_player_node_animations_changed(animations)

func _on_render_canvas_player_node_animations_changed(new_animation_names:Array[String]) -> void:
	if not is_node_ready():
		animations = new_animation_names
		return
		
	clear_list()
	for animation in new_animation_names:
		var animation_control: AnimationLine = animation_control_scene.instantiate()
		animation_control.name = animation
		animation_control.animation_name = animation
		animation_control.ready.connect(func():
			animation_control.play_button.button_down.connect(_on_animation_list_play_animation.bind( animation_control))
			animation_control.test_out_of_bounds_button.button_down.connect(_on_animation_list_test_animation.bind( animation_control))
		)
		
		animation_list_node.add_child(animation_control)
		animation_list_node.add_child(HSeparator.new())
		


func clear_list() -> void:
	for node in animation_list_node.get_children():
		node.queue_free()

func _on_animation_list_play_animation(animation_control: AnimationLine):
	if animation_control.play_button.text == "Stop":
		animation_changed.emit(AnimationEvent.stop(animation_control.animation_name, false))
	else:
		animation_changed.emit(AnimationEvent.play(animation_control.animation_name, false))

func _on_animation_list_test_animation(animation_control: AnimationLine):
	if animation_control.test_out_of_bounds_button.text == "Stop":
		animation_changed.emit(AnimationEvent.stop(animation_control.animation_name, true))
	elif animation_control.test_out_of_bounds_button.text == "Continue":
		animation_changed.emit(AnimationEvent.continue_(animation_control.animation_name, true))
	else:
		animation_changed.emit(AnimationEvent.play(animation_control.animation_name, true))


func _on_render_canvas_animation_changed(event:AnimationEvent) -> void:
	var animation_node: AnimationLine = animation_list_node.get_node(event.animation_name)
	var button: Button = animation_node.play_button if not event.is_test else animation_node.test_out_of_bounds_button

	
	match event.action:
		Enums.AnimationEventAction.PLAYING:
			print("PLAYING | %s | %s" % [button.text, event.is_test])
			button.text = "Stop"
			pass
		Enums.AnimationEventAction.PLAY:
			print("PLAY | %s | %s" % [button.text, event.is_test])
			pass
		Enums.AnimationEventAction.PAUSED:
			print("PAUSED | %s | %s" % [button.text, event.is_test])
			button.text = "Continue"
			pass
		Enums.AnimationEventAction.FINISHED:
			print("FINISHED | %s | %s" % [button.text, event.is_test])
			button.text = "Play" if not event.is_test else "Test"
			pass


func _on_option_button_item_selected(index: int) -> void:
	animation_play_mode_changed.emit(index)
