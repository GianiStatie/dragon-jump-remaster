extends MarginContainer

@onready var bar_texture: Panel = $Texture
@onready var icon_container: Node = $IconContainer
@onready var crown_icon: Sprite2D = $Crown

var x_start: float = 0.0
var x_length: float = 0.0
var player_with_crown: String = ""
var crown_shift_on_pickup: int = 14


func _ready() -> void:
	var x_end = self.get_theme_constant("margin_right")
	x_start = self.get_theme_constant("margin_left")
	x_length = self.size.x - x_start - x_end
	
	SignalBus.player_touched_crown.connect(_on_player_touched_crown)
	SignalBus.player_dropped_crown.connect(_on_player_dropped_crown)


func update_player_progress(progress_data: Dictionary) -> void:
	for node in icon_container.get_children():
		var progress = progress_data.get(node.name)
		if progress:
			set_progress(node, progress)
			if node.name == player_with_crown:
				set_progress(crown_icon, progress)


func set_progress(node: Sprite2D, progress: float) -> void:
	var pixel_progress = x_length * progress
	node.position.x = x_start + pixel_progress


func _on_player_touched_crown(player: Player):
	player_with_crown = player.name
	crown_icon.position.y -= crown_shift_on_pickup


func _on_player_dropped_crown(_player: Player):
	player_with_crown = ""
	crown_icon.position.y += crown_shift_on_pickup
