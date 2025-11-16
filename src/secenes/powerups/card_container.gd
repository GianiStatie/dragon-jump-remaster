extends Panel

const margin_shift := Vector4()

@onready var card_scene = preload("res://src/secenes/powerups/card_scene.tscn")



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		draw_card()


func draw_card():
	var card_object = card_scene.instantiate()
	self.add_child(card_object)
	card_object.draw("test")
