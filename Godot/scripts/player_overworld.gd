extends KinematicBody2D

var moveVec = Vector2()

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	pass
	
	
func _input(event):
	moveVec = Vector2(0,0)
	if not event.is_echo():
		
		if event.is_action_pressed("left"):
			
			moveVec.x -= 1
			
		elif event.is_action_pressed("right"):
			
			moveVec.x += 1
		
		elif event.is_action_pressed("up"):
			
			moveVec.y -= 1
			
		elif event.is_action_pressed("down"):
			
			moveVec.y += 1
		
func _fixed_process(dt):
	moveVec = move_to(get_pos()+moveVec*8)
	if is_colliding():
		if get_collider().is_in_group("world"):
			get_tree().change_scene("res://scenes//world0.tscn")
	