class_name StompState
extends State


func enter(_msg := {}) -> void:
	owner.show_afterimage = true
	owner.velocity.y = -owner.jump_velocity
	owner.add_modifier("stomp", {"velocity": Vector2(0, 1)})
	owner.play_animation(self.name)


func physics_update(_delta: float) -> void:
	if owner.is_on_floor():
		state_machine.transition_to("Idle")


func exit() -> void:
	owner.velocity.x = owner.max_speed * 0.35 * owner.facing_direction
	owner.modifiers.erase("stomp")
	owner.show_afterimage = false
