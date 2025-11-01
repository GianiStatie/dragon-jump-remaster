class_name FallState
extends State


func enter(msg := {}) -> void:
	if msg.has("was_walled"):
		owner.add_modifier("walled_fall", {"velocity": Vector2(0, 1)})
	owner.play_animation(self.name)


func physics_update(_delta: float) -> void:
	if owner.is_on_floor():
		if not owner.started_walking:
			state_machine.transition_to("Idle")
		else:
			owner.velocity = owner.velocity * 0.75
			state_machine.transition_to("Move")
	
	if owner.is_on_wall():
		#state_machine.transition_to("Walled")
		pass


func exit() -> void:
	owner.modifiers.erase("walled_fall")
