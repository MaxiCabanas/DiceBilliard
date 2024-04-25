@tool
extends Skeleton3D

const dice_types = preload("res://Scripts/dice_types.gd")

# button to run my settup function
@export var build_labels: bool = false : set = _build_labels

# getting references to nodes
@onready var dice_controller = $".." as DiceController
@onready var label_root = $"../Labels"

func _build_labels(value) -> void:
	
	#remove previous labels
	var children = label_root.get_children()
	for node in children:
		label_root.remove_child(node)
		node.queue_free()
	
	var dice_data = dice_types.new()
	var dice_type = dice_controller.Type

	for i in get_bone_count():
		var newLabel = Label3D.new()
		label_root.add_child(newLabel)
		newLabel.owner = dice_controller
		
		var face_value = dice_data.DefaultValues[dice_type][i]
		newLabel.text = face_value
		newLabel.name = "Face " + face_value
		newLabel.position = get_bone_pose_position(i)
		newLabel.look_at(dice_controller.position)

func _ready():
	pass
	
		
func _on_dice_rolled():
	pass # Replace with function body.
