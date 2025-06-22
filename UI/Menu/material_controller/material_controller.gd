extends Control

signal color_shader_active(is_active: bool)
signal material_changed(shaderName: ShaderMaterial, debug_draw: float)

@export var mono : ShaderMaterial
@export var no_palette : ShaderMaterial
@export var palette : ShaderMaterial
@export var normal : ShaderMaterial

#@export var player_path : NodePath
#@onready var color_shader = $"../../../VSplitContainer/PanelContainer/Renderscene/after_effect/after_viewport/ColorShader"
#@onready var viewport = $"../../../VSplitContainer/PanelContainer/Renderscene/first_render/Viewport"

#func _ready():
#	var player_scene = get_node(player_path)

func _on_mono_chrome_button_up():
	material_changed.emit(mono, 0)
#	color_shader.material = color_shader.mono
#	viewport.debug_draw = 0


func _on_color_palette_button_up():
	material_changed.emit(palette, 0)
#	color_shader.material = color_shader.palette
#	viewport.debug_draw = 0


func _on_color_limit_button_up():
	material_changed.emit(no_palette, 0)
#	color_shader.material = color_shader.no_palette
#	viewport.debug_draw = 0


func _on_normal_render_button_up():
	material_changed.emit(normal, 5)
#	color_shader.material = color_shader.normal
#	viewport.debug_draw = 5


func _on_background_shader_toggled(toggled_on:bool) -> void:
	color_shader_active.emit(toggled_on)
