extends Node

var default_dir: String = "."

func _ready() -> void:
	_handle_run_args()

func _handle_run_args():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	print(arguments)
	if arguments.has("default-dir"):
		default_dir = arguments.get("default-dir")
