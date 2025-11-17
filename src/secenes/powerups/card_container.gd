extends Panel

const margin_shift_draw := [-10, 0, 0, 10]
const margin_shift_play := [10, 0, 0, -10]
@onready var card_scene = preload("res://src/secenes/powerups/card_scene.tscn")


func shift_card_positions(backward: bool = false) -> void:
	var offset = margin_shift_play if backward else margin_shift_draw
	for child in self.get_children():
		child.shift_by(offset)


func _on_player_picked_powerup(powerup_name: String, id: int) -> void:
	shift_card_positions()
	var card_object = card_scene.instantiate()
	self.add_child(card_object)
	card_object.name = str(id)
	card_object.draw(powerup_name)


func _on_player_used_powerup(id: int) -> void:
	shift_card_positions(true)
	for child in self.get_children():
		if child.name == str(id):
			remove_child(child)
			child.queue_free()
			break
