class_name MoveState
extends State


func enter(_msg := {}) -> void:
	owner.play_animation(self.name)


func physics_update(_delta: float) -> void:
	if owner.is_on_wall():
		owner.facing_direction *= -1
	
	if owner.wants_to_jump and not owner.needs_to_release:
		state_machine.transition_to("Jump")
	
	if not owner.is_on_floor():
		state_machine.transition_to("Fall")
