class_name JumpCommand
extends Command


class Params:
	var input: bool
	
	func _init(should_jump: bool) -> void:
		self.input = should_jump


func execute(player: Player, data: Object = null) -> void:
	if data is Params:
		player.set_jump(data.input)
