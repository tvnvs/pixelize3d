class_name RenderConfig

const FILE_NAME_ANGLE_CONST: String                         = "_angle_"
const FILE_NAME_DEFAULT_PLACEHOLDER: String                 = "{{default}}"
const FILE_NAME_ANIMATION_NAME_PLACEHOLDER: String          = "{{animation}}"
const FILE_NAME_PLAYER_ROTATION_DEG_PLACEHOLDER: String     = "{{p_angle_deg}}"
const FILE_NAME_PLAYER_ROTATION_DEG_INT_PLACEHOLDER: String = "{{p_angle_deg_int}}"

var state: Enums.RenderMode                          = Enums.RenderMode.ONE
var export_rotation_angles: int                             = 1
var single_file_animation: bool                             = true
var fps: int                                                = 16
var frames_per_row: int = 0
var outpu_dir: String
var export_file_name_pattern: String


func build_file_path(animation_gen_name: String, current_rotation_deg: float) -> String:
	return outpu_dir + build_file_name(animation_gen_name, current_rotation_deg)
	
func build_file_name(animation_gen_name: String, current_rotation_deg: float) -> String:
	var file_name: String = animation_gen_name+".png"
	if animation_gen_name == null or animation_gen_name.is_empty():
		return file_name
	var animation_name: String = animation_gen_name
	var rotation_deg = current_rotation_deg

	if animation_name.contains(FILE_NAME_ANGLE_CONST):
		var split: PackedStringArray = animation_name.split(FILE_NAME_ANGLE_CONST)
		animation_name = split[0]
		rotation_deg = float(split[1])
	file_name = export_file_name_pattern
	if file_name.contains(FILE_NAME_DEFAULT_PLACEHOLDER):
		file_name = file_name.replacen(FILE_NAME_DEFAULT_PLACEHOLDER, animation_gen_name)
	if file_name.contains(FILE_NAME_ANIMATION_NAME_PLACEHOLDER):
		file_name = file_name.replacen(FILE_NAME_ANIMATION_NAME_PLACEHOLDER, animation_name)
	if file_name.contains(FILE_NAME_PLAYER_ROTATION_DEG_PLACEHOLDER):
		file_name = file_name.replacen(FILE_NAME_PLAYER_ROTATION_DEG_PLACEHOLDER, "%.2f" % rotation_deg)
	if file_name.contains(FILE_NAME_PLAYER_ROTATION_DEG_INT_PLACEHOLDER):
		file_name = file_name.replacen(FILE_NAME_PLAYER_ROTATION_DEG_INT_PLACEHOLDER, "%03d" % int(floor(rotation_deg)))

	return file_name