class_name DisolveBlock
extends StaticBody2D

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func reset() -> void:
	timer.stop()
	animation_player.play("RESET")


func _on_area_2d_area_entered(_area: Area2D) -> void:
	animation_player.play("Disolve")


func _on_timer_timeout() -> void:
	animation_player.play("Repair")
