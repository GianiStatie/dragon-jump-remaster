extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var level_music: AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	SignalBus.player_touched_crown.connect(_on_player_touched_crown)


func freeze_frame(timescale: float, duration: float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func _on_player_touched_crown(player: Player):
	SignalBus.player_movement_paused.emit()
	camera.zoom_on(player.global_position)
	camera.zoom_on(player.global_position)
	#camera.apply_shake(20)
	#freeze_frame(.2, .5)
	#var tween = create_tween()
	#tween.tween_property(level_music, "pitch_scale", 1.25, 1)
