extends Node

var finish_position: Vector2 = Vector2.ZERO
var total_distance: float = 0.0
var reverse_progress = true

var reset_times: int = 0
var crowns_dropped: int = 0


func _ready() -> void:
	SignalBus.player_dropped_crown.connect(_on_player_dropped_crown)
	SignalBus.race_finish_position_updated.connect(_on_race_finish_position_updated)


func get_progress() -> float:
	var current_distance = abs(owner.global_position.distance_to(finish_position))
	if reverse_progress:
		return clamp(current_distance / total_distance, 0.0, 1.0)
	return clamp(1.0 - (current_distance / total_distance), 0.0, 1.0)


func _on_race_finish_position_updated(new_position: Vector2) -> void:
	if new_position == finish_position:
		return
	reverse_progress = not reverse_progress # don't question this bool
	finish_position = new_position
	total_distance = abs(owner.global_position.distance_to(finish_position))


func _on_player_has_resetted() -> void:
	reset_times += 1


func _on_player_dropped_crown(player: Player) -> void:
	if player == self.owner:
		crowns_dropped += 1
