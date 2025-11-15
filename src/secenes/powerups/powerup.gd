extends Area2D

var powerups = [
	"DoubleJump",
	"Stomp",
	"Dash"
]


func get_powerup() -> String:
	#return powerups.pick_random() 
	return "Grapple"
