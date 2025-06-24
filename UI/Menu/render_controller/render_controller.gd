extends VBoxContainer


signal render_state_changed(state: RenderCanvas.RenderMode, angle_nr: int)
signal render_file_name_pattern_changed(file_name_pattern: String)
signal render_start(output_dir: String)
signal render_single_file_animation_changed(single_file_animation: bool)

const ONE_FILE_NAME: String = "{{animation}}.png"
const ALL_FILE_NAME: String = "ALL.png"
const EIGHT_SINGLE_FILE_NAME: String = "{{animation}}_8.png"
const EIGHT_FILE_NAME: String = "{{animation}}_{{p_angle_deg_int}}.png"

const SIXTEEN_SINGLE_FILE_NAME: String = "{{animation}}_16.png"
const SIXTEEN_FILE_NAME: String = "{{animation}}_{{p_angle_deg_int}}.png"

@onready var render_mode_node: MenuButton = $RenderMode 
@onready var render_mode_label_node: Label = $RenderMode/Label 
@onready var menu_button_node: MenuButton = $MenuButton
@onready var file_name_pattern_node: TextEdit = $FileNamePattern
@onready var single_file_toggle_node: CheckBox = $SingleFileToggle


var id_selected: int = 0


func _ready():
	var popup = render_mode_node.get_popup()
	popup.connect("id_pressed", file_menu)
	file_menu(0)
	_on_single_file_toggle_toggled(single_file_toggle_node.is_pressed())


func _on_file_name_pattern_text_changed() -> void:
	_emit_file_name_pattern_changed(file_name_pattern_node.text)
	
func file_menu(id):
	single_file_toggle_node.visible = false
	id_selected = id
	match id:
		0:
			render_state_changed.emit(RenderCanvas.RenderMode.ONE, 1)
			file_name_pattern_node.placeholder_text = ONE_FILE_NAME
		1:
			render_state_changed.emit(RenderCanvas.RenderMode.ALL, 1)
			file_name_pattern_node.placeholder_text = ALL_FILE_NAME
		2:
			render_state_changed.emit(RenderCanvas.RenderMode.MULTIPLE_ANGLES, 8)
			file_name_pattern_node.placeholder_text = EIGHT_SINGLE_FILE_NAME if single_file_toggle_node.is_pressed() else EIGHT_FILE_NAME 
			single_file_toggle_node.visible = true
		3:
			render_state_changed.emit(RenderCanvas.RenderMode.MULTIPLE_ANGLES, 16)
			file_name_pattern_node.placeholder_text = SIXTEEN_SINGLE_FILE_NAME if single_file_toggle_node.is_pressed() else SIXTEEN_FILE_NAME
			single_file_toggle_node.visible = true

	render_mode_label_node.text = render_mode_node.get_popup().get_item_text(id)
	if file_name_pattern_node.text.is_empty():
		_emit_file_name_pattern_changed(file_name_pattern_node.placeholder_text)

func _on_start_render_button_down() -> void:
	select_output_path()
	
func select_output_path() -> void:
	menu_button_node.file_menu(1)

func _on_file_dialog_dir_selected(dir):
	dir = str(dir) + "/"
	render_start.emit(dir)

func _emit_file_name_pattern_changed(file_name_pattern: String):
	render_file_name_pattern_changed.emit(file_name_pattern)
	print("New File name pattern: %s" % file_name_pattern)


func _on_single_file_toggle_toggled(toggled_on:bool) -> void:
	render_single_file_animation_changed.emit(toggled_on)
	file_menu(id_selected)
