class_name DiceController
extends RigidBody3D

const dice_types = preload("res://Scripts/dice_types.gd")

@export var Type = dice_types.DiceType.D20

@export_category("Dice Physics")
@export var LaunchCurve: Curve
@export var MaxLaunchDistance: float = 10
@export var LaunchMultiplier: float = 1

var is_being_overlapped: bool = false
var is_being_grabbed: bool = false
var last_sleeping_state: bool = false

@onready var viewport: Viewport = get_viewport()
@onready var camera: Camera3D = viewport.get_camera_3d()

signal dice_rolled

func _physics_process(delta):
	if sleeping != last_sleeping_state:
		last_sleeping_state = sleeping
		if sleeping:
			dice_rolled.emit()

func _unhandled_input(event):
	if event.is_action_type():
		if event.is_action_pressed("grab") && is_being_overlapped:
			is_being_grabbed = true
		elif event.is_action_released("grab") && is_being_grabbed:
			is_being_grabbed = false
			apply_impulse(_calculate_impulse())
			
# Need rework because with perspective is broken
func _calculate_impulse():
	var mousePos = viewport.get_mouse_position()
	var distance = (camera.position - position).length()
	
	var drag_position = camera.project_position(mousePos, distance)
	
	#Make the result of raycast be at the same height of the dice.
	drag_position.y = position.y
	
	var temp_force = position - drag_position
	
	var remapedForce = remap(temp_force.length(), 0.0, MaxLaunchDistance, 0.0, 1.0)
	var finalLaunchForce = LaunchCurve.sample_baked(remapedForce) * LaunchMultiplier
	
	temp_force = temp_force.normalized() * finalLaunchForce
	return temp_force

# Can be used insted of the in-build sleeping variable if want to remove delay
# or doesn't want to relly on sleeping system.
func _is_dice_still():
	#return linear_velocity.length_squared() < 0.0001
	const tolerance: float = 0.00001
	var is_still: bool = false
	is_still = is_still || abs(linear_velocity.x) < tolerance
	is_still = is_still || abs(linear_velocity.y) < tolerance
	is_still = is_still || abs(linear_velocity.z) < tolerance
	return is_still

func _on_detection_area_mouse_entered():
	is_being_overlapped = true

func _on_detection_area_mouse_exited():
	is_being_overlapped = false
