class_name IdleState
extends State


func enter(_msg := {}) -> void:
	owner.last_floor_position = owner.global_position
	owner.play_animation(self.name)


func physics_update(_delta: float) -> void:
	if not owner.started_walking:
		return
	
	if not owner.is_on_floor():
		state_machine.transition_to("Fall")
	else:
		state_machine.transition_to("Move")
