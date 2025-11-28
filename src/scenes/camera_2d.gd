extends Camera2D

@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()

var noise_i: float = 0.0
var noise_seed: float = 30.0

var shake_decay_rate: float = 3.0
var shake_strength: float = 0.0

var initial_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	initial_offset = self.offset


func _process(delta: float) -> void:
	if shake_strength <= 1:
		return
	
	shake_strength = snapped(lerp(shake_strength, 0.0, shake_decay_rate * delta), 0.01)
	var shake_offset = get_random_offset()
	self.offset = initial_offset + shake_offset
	
	if shake_strength <= 1:
		self.offset = initial_offset


func zoom_on(target_position: Vector2, zoom_factor: float = 5.0):
	position = target_position
	zoom = Vector2(zoom_factor, zoom_factor)


func apply_shake(strength: float = 30):
	noise_i = 0.0
	shake_strength = strength


func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
