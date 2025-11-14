class_name DoubleJumpState
extends JumpState


func enter(_msg := {}) -> void:
	super()
	owner.show_afterimage = true


func exit() -> void:
	super()
	owner.show_afterimage = false
