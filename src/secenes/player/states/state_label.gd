extends Control

@onready var main_scene = "res://main.tscn"


func _on_selection() -> void:
	get_tree().change_scene_to_file(main_scene)
	#self.visible = false


func _on_server_button_pressed() -> void:
	NetworkHandler.start_server()
	_on_selection()


func _on_client_button_pressed() -> void:
	NetworkHandler.start_client()
	_on_selection()
