class_name JumpState
extends State

@onready var timer: Timer = $Timer
var was_on_wall: bool = false


func _ready() -> void:
	timer.timeout.connect(_on_jump_timer_timeout)


func enter(_msg := {}) -> void:
	was_on_wall = false
	timer.start(owner.jump_time_to_peak)
	owner.velocity.y = owner.jump_velocity
	owner.play_animation(self.name)


func physics_update(_delta: float) -> void:
	if owner.is_on_wall():
		was_on_wall = true
	
	if owner.is_on_ceiling():
		owner.add_modifier("spiderman", {"velocity": Vector2(1, 0)})
	
	if (was_on_wall and not owner.is_on_wall()) or owner.is_on_floor():
		owner.velocity.x *= 0.5
		state_machine.transition_to("Move")
	
	elif not owner.wants_to_jump:
		_on_jump_timer_timeout()


func exit() -> void:
	was_on_wall = false
	timer.stop()
	
	owner.wants_to_jump = false
	owner.velocity.y = max(owner.velocity.y, 0)
	owner.remove_modifier("spiderman")


func _on_jump_timer_timeout() -> void:
	if was_on_wall:
		state_machine.transition_to("Walled")
	else: 
		state_machine.transition_to("Fall")
