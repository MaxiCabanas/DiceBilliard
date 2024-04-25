@tool
extends EditorScript

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var dice_data = dice_types.new()
	var dice_type = dice_controller.Type

	for i in get_bone_count():
		var newLabel = Label3D.new()
		label_root.add_child(newLabel)
		
		newLabel.text = dice_data.DefaultValues[dice_type][i]
		newLabel.position = get_bone_pose_position(i)
		newLabel.look_at(dice_controller.position)
