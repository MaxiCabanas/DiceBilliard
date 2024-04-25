class_name DiceController
extends RigidBody3D

const dice_types = preload("res://Scripts/dice_types.gd")

@export var Type = dice_types.DiceType.D20

@export_category("Dice Physics")
@export var LaunchCurve: Curve
@export var MaxLaunchDistance: float = 10
@export var LaunchMultiplier: float = 1

var impulse: Vector3
var is_being_overlapped: bool = false
var is_being_grabbed: bool = false

@onready var viewport: Viewport = get_viewport()
@onready var camera: Camera3D = viewport.get_camera_3d()

signal dice_rolled

func _physics_process(delta):
	if is_being_grabbed:
		var mousePos = viewport.get_mouse_position()
		var distance = (camera.position - position).length()
		
		var drag_position = camera.project_position(mousePos, distance)
		
		#Make the result of raycast be at the same height of the dice.
		drag_position.y = position.y
		
		impulse = position - drag_position
		
		var remapedForce = remap(impulse.length(), 0.0, MaxLaunchDistance, 0.0, 1.0)
		var finalLaunchForce = LaunchCurve.sample_baked(remapedForce) * LaunchMultiplier
		
		impulse = impulse.normalized() * finalLaunchForce

func _process(delta):
	if is_being_overlapped && Input.is_action_pressed("grab"):
		is_being_grabbed = true
			
	if Input.is_action_just_released("grab"):
		if is_being_grabbed:
			is_being_grabbed = false
			apply_impulse(impulse)

func _on_detection_area_mouse_entered():
	is_being_overlapped = true

func _on_detection_area_mouse_exited():
	is_being_overlapped = false
