class_name Swing
extends State


func enter(_msg := {}) -> void:
	owner.launch_grappling_hook()


func physics_update(_delta: float) -> void:
	if owner.is_on_wall():
		state_machine.transition_to("Walled")
	
	if owner.is_on_floor():
		state_machine.transition_to("Move")
	
	if not owner.wants_to_jump:
		state_machine.transition_to("Fall")


func exit() -> void:
	owner.release_grappling_hook()


func _on_gapling_hook_should_release() -> void:
	state_machine.transition_to("Fall")
