class_name Powerup
extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var type: String = ""
var color: Color = Color()


func init(args: Array) -> void:
	type = args[0]
	color = Constants.POWERUPS[type]["color"]


func _ready() -> void:
	sprite.material.set_shader_parameter("replace_0", color)


func get_powerup() -> String:
	if type:
		return type
	var powerup_names = Constants.POWERUPS.keys()
	return powerup_names.pick_random()
