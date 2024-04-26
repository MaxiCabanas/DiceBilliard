class_name DiceController
extends RigidBody3D

enum {
	STILL,
	ROLLING,
	GRABBED,
	RELEASED
}

const dice_types = preload("res://Scripts/dice_types.gd")

@export var Type = dice_types.DiceType.D20

@export_category("Dice Physics")
@export var LaunchCurve: Curve
@export var MaxLaunchDistance: float = 10
@export var LaunchMultiplier: float = 1

var impulse: Vector3
var is_being_overlapped: bool = false
var must_emit: bool = false
#var is_being_grabbed: bool = false
#var is_rolling: bool = false
#var is_rolling_from_player_interaction: bool = false

var current_state = STILL

@onready var viewport: Viewport = get_viewport()
@onready var camera: Camera3D = viewport.get_camera_3d()

signal dice_rolled

func _physics_process(delta):
	if _is_dice_state(GRABBED):
		var mousePos = viewport.get_mouse_position()
		var distance = (camera.position - position).length()
		
		var drag_position = camera.project_position(mousePos, distance)
		
		#Make the result of raycast be at the same height of the dice.
		drag_position.y = position.y
		
		impulse = position - drag_position
		
		var remapedForce = remap(impulse.length(), 0.0, MaxLaunchDistance, 0.0, 1.0)
		var finalLaunchForce = LaunchCurve.sample_baked(remapedForce) * LaunchMultiplier
		
		impulse = impulse.normalized() * finalLaunchForce
	
	elif _is_dice_still() && _is_dice_state(ROLLING):
		_set_state(STILL)
		if must_emit:
			must_emit = false
			dice_rolled.emit()
	elif !_is_dice_still() && _is_dice_state(RELEASED):
		_set_state(ROLLING)
		must_emit = true

func _process(delta):
	if _is_dice_state(STILL) && is_being_overlapped && Input.is_action_pressed("grab"):
		#is_being_grabbed = true
		_set_state(GRABBED)
		
	if _is_dice_state(GRABBED) && Input.is_action_just_released("grab"):
		_set_state(RELEASED)
		apply_impulse(impulse)
			
func _is_dice_still():
	#return linear_velocity.length_squared() < 0.0001
	const tolerance: float = 0.00001
	var is_still: bool = false
	is_still = is_still || abs(linear_velocity.x) < tolerance
	is_still = is_still || abs(linear_velocity.y) < tolerance
	is_still = is_still || abs(linear_velocity.z) < tolerance
	return is_still

func _set_state(new_state):
	if current_state != new_state:
		current_state = new_state

func _is_dice_state(state):
	return current_state == state

func _on_detection_area_mouse_entered():
	is_being_overlapped = true

func _on_detection_area_mouse_exited():
	is_being_overlapped = false
