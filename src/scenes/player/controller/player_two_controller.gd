class_name PlayerTwoController
extends PlayerCharacterController


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_two_jump"):
		jump_command.execute(player, JumpCommand.Params.new(true))
	elif event.is_action_released("player_two_jump"):
		jump_command.execute(player, JumpCommand.Params.new(false))
	elif event.is_action_pressed("player_two_reset"):
		reset_command.execute(player)
