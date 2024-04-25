class_name DiceController
extends RigidBody3D

var impulse: Vector3
var mousePos: Vector3
var clickNormal: Vector3

func _ready():
	pass


func _process(delta):
	if Input.is_action_pressed("grab"):
		$DebugText.text = _debug_vector(mousePos)
		
	if Input.is_action_just_pressed("hit"):
		
		var rng = RandomNumberGenerator.new()
		var x = rng.randf_range(-1.0, 1.0)
		var y = rng.randf_range(-1.0, 1.0)
		var z = rng.randf_range(-1.0, 1.0)
		
		var power = rng.randf_range(1.0, 10.0)
		
		self.apply_impulse(Vector3(x,y,z).normalized() * power)


func _on_detection_area_input_event(camera, event, position, normal, shape_idx):
	mousePos = position
	clickNormal = normal

func _debug_vector(vector):
	var finalString = "("
	finalString += String.num(vector.x, 2) + " , "
	finalString += String.num(vector.y, 2) + " , "
	finalString += String.num(vector.z, 2) + ")"
	return finalString
