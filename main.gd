extends Control



@export var file_button_path: NodePath
@export var menu_button_path: NodePath

@onready var viewport_options: ViewportController = %ViewportOptions
@onready var render_canvas: RenderCanvas = %RenderCanvas
@onready var file_button: MenuButton = %FileButton

var player_node: Node3D
var camera_node: Node3D


func _ready():
	file_button.connect("model_load_triggered", _on_model_load_triggered)

	var c: Callable = Callable(self, "file_drop_path")
	get_tree().get_root().connect('files_dropped', c)
	



func _on_model_load_triggered(path: String):
	player_node = render_canvas.load_new_player_model(path)


func file_drop_path(files):
	_on_model_load_triggered(files[0])


	
