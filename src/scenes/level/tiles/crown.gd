extends Area2D

@onready var sfx = $AudioStreamPlayer2D
var was_picked = false


func _on_area_entered(_area: Area2D) -> void:
	if not was_picked:
		sfx.play()
		was_picked = true
