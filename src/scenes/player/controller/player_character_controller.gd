class_name PlayerCharacterController
extends Node

var player: Player

var jump_command: Command = JumpCommand.new()
var reset_command: Command = ResetCommand.new()


func _init(new_player: Player) -> void:
	self.player = new_player
