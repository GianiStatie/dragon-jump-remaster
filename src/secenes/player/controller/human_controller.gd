class_name HumanController
extends PlayerController


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_jump"):
		jump_command.execute(player, JumpCommand.Params.new(true))
	elif event.is_action_released("player_jump"):
		jump_command.execute(player, JumpCommand.Params.new(false))
	elif event.is_action_pressed("player_reset"):
		reset_command.execute(player)
