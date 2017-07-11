extends Area2D
export var triggerGroup = "Enemy"
export var triggerFuncgion = ""
func _ready():
	pass

func _on_Area2D_body_enter( body ):
	if body.is_in_group("Player"):
		get_tree().call_group(0,triggerGroup,"activate_bat",body)
		print(get_tree().get_nodes_in_group(triggerGroup))
		
