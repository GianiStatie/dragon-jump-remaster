class_name WalledState
extends State


func enter(_msg := {}) -> void:
	owner.velocity.x = 0
	owner.modifiers["walled"] = {"velocity": Vector2(-0.01, 0.69)}
	owner.play_animation(self.name)
	_update_owner_facing_direction()


func physics_update(_delta: float) -> void:
	if owner.is_on_floor():
		state_machine.transition_to("Idle", {"was_walled": true})
		
	elif not owner.is_on_wall():
		state_machine.transition_to("Fall", {"was_walled": true})
		
	elif owner.wants_to_jump:
		owner.set_speedup_progress(0.5) # rebound jump with increased speed
		state_machine.transition_to("Jump", {"was_walled": true})


func exit() -> void:
	owner.modifiers.erase("walled")


func _update_owner_facing_direction() -> void:
	var walled_direction = _get_walled_direction()
	if walled_direction != Vector2.ZERO:
		owner.facing_direction = walled_direction.x
	else:
		owner.facing_direction *= -1


func _get_walled_direction():
	var collision = owner.get_last_slide_collision()
	if collision:
		var normal = collision.get_normal()
		if abs(normal.x) > abs(normal.y):  # Check if the collision is mostly horizontal
			return normal
	return Vector2.ZERO
