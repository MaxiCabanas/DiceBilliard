@tool
extends Skeleton3D

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
	
	var dice_type = dice_controller.Type

	for i in get_bone_count():
		var newLabel = Label3D.new()
		label_root.add_child(newLabel)
		newLabel.owner = dice_controller
		
		var face_value = DiceTypes.DefaultValues[dice_type][i]
		newLabel.text = face_value
		newLabel.name = "Face " + face_value
		newLabel.position = get_bone_pose_position(i)
		newLabel.look_at(dice_controller.position)

func _ready():
	pass
	
		
func _on_dice_rolled():
	for i in get_bone_count():
		var dir = to_global(get_bone_pose_position(i)) - global_position
		if _is_bone_aiming_up(dir.normalized()):
			print(DiceTypes.DefaultValues[dice_controller.Type][i])
			return
	
	#WE SHOULD NEVER HIT THIS
	print("SOMETHING WENT WRONG DETECTING ROLLED NUMBER")
	print(dice_controller.linear_velocity)
	print(dice_controller._is_dice_still())
	for i in get_bone_count():
		var dir = to_global(get_bone_pose_position(i)) - global_position
		print("bone " + String.num(i))
		print(dir.normalized().y)

func _is_bone_aiming_up(bone_dir):
	const tolerance: float = 0.01
	return snappedf(abs(bone_dir.y - 1.0), tolerance) <= tolerance;
