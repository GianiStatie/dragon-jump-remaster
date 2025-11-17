class_name Powerup
extends Area2D


func get_powerup() -> String:
	var powerup_names = Constants.POWERUPS.keys()
	return powerup_names.pick_random()
