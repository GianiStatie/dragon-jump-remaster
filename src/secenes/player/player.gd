class_name Player
extends CharacterBody2D

# movement properties
@export var max_speed: float = 110.0
@export var default_friction: float = 1000.0     # Default friction when on normal surfaces

# jump properties
@export var jump_height: float = 56.0            # Height in pixels
@export var jump_time_to_peak: float = 0.4       # Time in seconds to reach peak
@export var jump_time_to_descent: float = 0.3    # Time in seconds to descent

# Physics properties
var jump_velocity: float = ((-2.0 * jump_height) / jump_time_to_peak)         # Calculated jump velocity
var jump_gravity: float  = (2.0 * jump_height) / (jump_time_to_peak ** 2)     # Calculated gravity for jump
var fall_gravity: float  = (2.0 * jump_height) / (jump_time_to_descent ** 2)  # Calculated gravity for fall

# State
@onready var state_machine: StateMachine = $StateMachine
@onready var initial_state: State = $StateMachine/Idle

# Controllers
@onready var controller_container: Node = $ControllerContainer
var active_controller: PlayerController = null


# Nodes
@onready var sprite: Sprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Reset params
var current_friction: float = default_friction   # Current friction based on surface
var facing_direction: int = Vector2i.RIGHT.x
var started_walking: bool = false
var wants_to_jump: bool = false
var needs_to_release: bool = false
var modifiers: Dictionary = {}
var starting_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	starting_position = global_position
	set_controller(HumanController.new(self))
	
	reset()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_jump"):
		set_jump(true)
	elif event.is_action_released("player_jump"):
		set_jump(false)
	elif event.is_action_pressed("player_reset"):
		reset()


func set_controller(controller: PlayerController) -> void:
	for child in controller_container.get_children():
		child.queue_free()
	
	active_controller = controller
	controller_container.add_child(controller)


func set_jump(input: bool) -> void:
	if input:
		if not started_walking:
			started_walking = true
			return
		wants_to_jump = true
	else:
		wants_to_jump = false
		needs_to_release = false


func reset() -> void:
	current_friction = default_friction 
	facing_direction = Vector2i.RIGHT.x
	started_walking = false
	wants_to_jump = false
	needs_to_release = false
	modifiers = {}
	
	velocity = Vector2.ZERO
	global_position = starting_position
	state_machine.transition_to(initial_state.name)
	
	_update_facing_direction()


func add_modifier(modifier_name: String, modifier_value: Dictionary) -> void:
	# TODO: make a modifier type object
	modifiers[modifier_name] = modifier_value


func remove_modifier(modifier_name: String) -> void:
	modifiers.erase(modifier_name)


func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)


func set_speedup_progress(progress: float) -> void:
	progress = clamp(progress, 0.0, 1.0)
	velocity.x = lerp(0.0, max_speed * facing_direction, progress)


func _physics_process(delta: float) -> void:
	if not started_walking:
		return
	
	velocity.x = move_toward(velocity.x, max_speed * facing_direction, current_friction * delta)
	velocity.y += _get_actual_gravity() * delta
	
	_apply_modifiers()
	_update_friction()
	_update_facing_direction()
	
	move_and_slide()


func _get_actual_gravity() -> float:
	return jump_gravity if velocity.y < 0 else fall_gravity


func _update_friction() -> void:
	if is_on_floor():
		# Check for surface type and update friction accordingly
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() == null:
				return
			if collision.get_collider().has_method("get_friction"):
				current_friction = collision.get_collider().get_friction()
				return
		# If no special surface, use default friction
		current_friction = default_friction
	else:
		# In air, use default friction
		current_friction = default_friction


func _update_facing_direction() -> void:
	sprite.scale.x = facing_direction


func _apply_modifiers() -> void:
	for modifier in modifiers.values():
		velocity *= modifier.get("velocity", 1.0) 
