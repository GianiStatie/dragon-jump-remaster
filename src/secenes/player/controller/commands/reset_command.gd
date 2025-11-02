class_name ResetCommand
extends Command


func execute(player: Player, _data: Object = null) -> void:
	player.reset()
