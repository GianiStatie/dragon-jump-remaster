extends Node2D

@export var rest_length: float = 2.0
@export var stiffness: float = 10.0
@export var damping: float = 2.0

@onready var rope = $Line2D
@onready var grappling_points = $GrapplingPoints
@onready var grapple_indicator = $GrappleIndicator

var can_launch: bool = false
var launched: bool = false
var target: Vector2 = Vector2.ZERO

signal should_release


func _process(delta: float) -> void:
	update_tracked_target()
	
	if launched:
		_handle_grapple(delta)


func launch():
	if can_launch:
		launched = true
		rope.show()


func release():
	launched = false
	rope.hide()


func update_tracked_target():
	grapple_indicator.hide()
	
	if launched:
		return
	
	for ray in grappling_points.get_children():
		if ray.is_colliding():
			target = ray.get_collision_point()
			grapple_indicator.global_position = target
			grapple_indicator.show()
			can_launch = true
			return
	
	can_launch = false



func _handle_grapple(delta):
	var target_dir  = owner.global_position.direction_to(target)
	var target_dist = owner.global_position.distance_to(target)
	
	var displacement = target_dist - rest_length
	
	var force = Vector2.ZERO
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = owner.velocity.dot(target_dir)
		var grapple_damping = -damping * vel_dot * target_dir
		
		force = spring_force + grapple_damping
	
	if sign(force.x) != sign(owner.facing_direction):
		should_release.emit()
	
	owner.velocity += force * delta
	_update_rope()


func _update_rope():
	rope.set_point_position(1, to_local(target))
