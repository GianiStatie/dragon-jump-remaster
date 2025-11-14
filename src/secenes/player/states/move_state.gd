class_name MoveState
extends State


func enter(_msg := {}) -> void:
	owner.play_animation(self.name)


func physics_update(_delta: float) -> void:
	if owner.is_on_wall():
		owner.facing_direction *= -1
		owner.set_speedup_progress(0.5)
	
	if owner.velocity.x >= owner.max_speed * 0.9:
		owner.play_animation("Run")
	else:
		owner.play_animation(self.name)
	
	if owner.wants_to_jump and not owner.needs_to_release:
		state_machine.transition_to("Jump")
