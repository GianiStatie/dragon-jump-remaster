extends Node

const env_file_path = "res://.env"


func _ready() -> void:
	if FileAccess.file_exists(env_file_path):
		load_env(env_file_path)


func load_env(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open .env file: %s" % path)
		return

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var parts = line.split("=", false, 1)
		if parts.size() == 2:
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()
			OS.set_environment(key, value)
	file.close()
