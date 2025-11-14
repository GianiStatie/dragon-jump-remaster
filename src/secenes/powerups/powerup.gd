extends Area2D

var powerups = [
	"DoubleJump",
	"Stomp"
]


func get_powerup() -> String:
	#return powerups.pick_random()
	return "Dash"
