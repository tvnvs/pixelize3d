extends VBoxContainer


signal render_start(render_config: RenderConfig)

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


var render_config: RenderConfig = RenderConfig.new()
var id_selected: int = 0


func _ready():
	var popup = render_mode_node.get_popup()
	popup.connect("id_pressed", file_menu)
	file_menu(0)
	_on_single_file_toggle_toggled(single_file_toggle_node.is_pressed())


func _on_file_name_pattern_text_changed() -> void:
	render_config.export_file_name_pattern = file_name_pattern_node.placeholder_text
	
func file_menu(id):
	single_file_toggle_node.visible = false
	id_selected = id
	match id:
		0:
			render_config.state = Enums.RenderMode.ONE
			render_config.export_rotation_angles = 1
			file_name_pattern_node.placeholder_text = ONE_FILE_NAME
		1:
			render_config.state = Enums.RenderMode.ALL
			render_config.export_rotation_angles = 1
			file_name_pattern_node.placeholder_text = ALL_FILE_NAME
		2:
			render_config.state = Enums.RenderMode.MULTIPLE_ANGLES
			render_config.export_rotation_angles = 8
			file_name_pattern_node.placeholder_text = EIGHT_SINGLE_FILE_NAME if single_file_toggle_node.is_pressed() else EIGHT_FILE_NAME 
			single_file_toggle_node.visible = true
		3:
			render_config.state = Enums.RenderMode.MULTIPLE_ANGLES
			render_config.export_rotation_angles = 16
			file_name_pattern_node.placeholder_text = SIXTEEN_SINGLE_FILE_NAME if single_file_toggle_node.is_pressed() else SIXTEEN_FILE_NAME
			single_file_toggle_node.visible = true

	render_mode_label_node.text = render_mode_node.get_popup().get_item_text(id)
	if file_name_pattern_node.text.is_empty():
		render_config.export_file_name_pattern = file_name_pattern_node.placeholder_text

func _on_start_render_button_down() -> void:
	select_output_path()
	
func select_output_path() -> void:
	menu_button_node.file_menu(1)

func _on_file_dialog_dir_selected(dir):
	render_config.outpu_dir = str(dir) + "/"
	render_start.emit(render_config)


func _on_single_file_toggle_toggled(toggled_on:bool) -> void:
	render_config.single_file_animation = toggled_on
	file_menu(id_selected)
