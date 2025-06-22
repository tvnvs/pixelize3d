extends Control

var dir = ''

@onready var viewport_options: ViewportController = %ViewportOptions


@export var player_canvas_path: NodePath
@export var file_button_path: NodePath

@export var menu_button_path : NodePath

var player_canvas: Control
var file_button: MenuButton
var menu_button : MenuButton

var player_node: Node3D
var color_shader: ColorRect
var player_transform: Node3D




func _ready():
	player_canvas = get_node(player_canvas_path)
	file_button = get_node(file_button_path)
	menu_button = get_node(menu_button_path)
	
	color_shader = player_canvas.find_child("ColorShader")
	player_node = player_canvas.find_child("Player")
	file_button.connect("model_load_triggered", _on_model_load_triggered)
	
	player_transform = player_canvas.find_child("Player")
	
	var c = Callable(self,"file_drop_path")
	get_tree().get_root().connect('files_dropped',c)
	update_player_transform(player_node)

func _on_background_shader_toggled(button_pressed):
	if not button_pressed:
		color_shader.hide()
	else:
		color_shader.show()

func _on_model_load_triggered(path : String):
	if path.ends_with(".gltf") or path.ends_with(".glb"):
		var state = GLTFState.new()
		var importer = GLTFDocument.new()
		importer.append_from_file(path, state)
		var node = importer.generate_scene(state)
		
		node.transform = player_node.transform
		
		var node_parent = player_node.get_parent()
		player_node.name = "OldPlayer"
		player_node.queue_free()
		
		node_parent.add_child(node)
		node.set_owner(node_parent)
		player_node = node
		player_node.name = "Player"
		update_player_transform(node)


func update_player_transform(node):
	player_transform = node as Node3D
	viewport_options.set_player_position(player_transform.position)
	viewport_options.set_player_rotation_degrees(player_transform.rotation_degrees)
	viewport_options.set_player_scale(player_transform.scale)

func file_drop_path(files):
	_on_model_load_triggered(files[0])


func _on_position_transform_changed(_transform):
	player_transform.position=_transform


func _on_rotation_transform_changed(_transform):
	player_transform.rotation_degrees=_transform


func _on_scale_transform_changed(_transform):
	player_transform.scale=_transform
	
