extends VBoxContainer


signal render_state_changed(state: String)
signal render_start(output_dir: String)

@onready var render_mode_node: MenuButton = $RenderMode 
@onready var render_mode_label_node: Label = $RenderMode/Label 
@onready var menu_button_node: MenuButton = $MenuButton


func _ready():
	var popup = render_mode_node.get_popup()
	popup.connect("id_pressed", file_menu)


func file_menu(id):
	match id:
		0:
			render_state_changed.emit('one')
			render_mode_label_node.text  = 'Seperate Animations'
		1:
			render_state_changed.emit('all')
			render_mode_label_node.text = "All as a Spritesheet"
		2:
			render_state_changed.emit('eight')
			render_mode_label_node.text = "Eight directions"
		3:
			get_tree().quit()



func _on_start_render_button_down() -> void:
	select_output_path()
	
func select_output_path() -> void:
	menu_button_node.file_menu(1)

func _on_file_dialog_dir_selected(dir):
	dir = str(dir) + "/"
	render_start.emit(dir)
