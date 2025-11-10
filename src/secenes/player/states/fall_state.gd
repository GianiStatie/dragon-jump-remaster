class_name FallState
extends State


func enter(msg := {}) -> void:
	if msg.has("was_walled"):
		owner.add_modifier("walled_fall", {"velocity": Vector2(0, 1)})
	owner.play_animation(self.name)


func physics_update(_delta: float) -> void:
	if owner.wants_to_jump and owner.has_powerups():
		var powerup_name = owner.consume_powerup()
		if powerup_name == "DoubleJump":
			state_machine.transition_to("Jump")
	
	if owner.is_on_floor():
		if not owner.started_walking:
			state_machine.transition_to("Idle")
		else:
			owner.velocity = owner.velocity * 0.5
			state_machine.transition_to("Move")
	
	if owner.is_on_wall():
		state_machine.transition_to("Walled")


func exit() -> void:
	owner.modifiers.erase("walled_fall")
