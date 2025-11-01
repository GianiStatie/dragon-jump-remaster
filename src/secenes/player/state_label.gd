extends Label


func _on_state_machine_transitioned(state_name: Variant) -> void:
	text = state_name
