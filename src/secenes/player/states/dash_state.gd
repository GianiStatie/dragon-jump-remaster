class_name DashState
extends JumpState


func enter(_msg := {}) -> void:
	super()
	owner.velocity.y = 0
	owner.velocity.x = owner.max_speed * owner.facing_direction * 1.65
	owner.modifiers["dash"] = {"velocity": Vector2(1.0, -0.01)}
	owner.show_afterimage = true


func exit() -> void:
	super()
	owner.show_afterimage = false
	owner.remove_modifier("dash")
