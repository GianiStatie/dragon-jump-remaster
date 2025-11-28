extends VBoxContainer

@onready var card_container_p1: Panel = $CardContainer1
@onready var card_container_p2: Panel = $CardContainer2


func _ready() -> void:
	card_container_p2.visible = false


func map_player_signals(players: Array) -> void:
	var containers = [card_container_p1, card_container_p2]
	var is_splitscreen = len(players) > 1
	for i in range(len(players)):
		var player = players[i]
		var card_container = containers[i]
		player.picked_powerup.connect(card_container._on_player_picked_powerup)
		player.used_powerup.connect(card_container._on_player_used_powerup)
		card_container.visible = true
		card_container.is_splitscreen = is_splitscreen
