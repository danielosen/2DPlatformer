extends RigidBody2D

const TILE_45DOWN = 10
const TILE_45UP = 9
const TILE_SIZE = 16.0
const RAYCAST_MAX_LENGTH = 8

onready var sprite = get_node("Sprite")

var maxSpeed = 1 #has to be an integer for movement to be precise.

onready var tileMap = get_parent().get_node("TileMap")

func _ready():
	set_fixed_process(true)
	
func getInput():
	var x = 0
	var y = 0
	if Input.is_action_pressed("left"):
		x-= 1
	if Input.is_action_pressed("right"):
		x+= 1
	if Input.is_action_pressed("down"):
		y += 1
	if Input.is_action_pressed("up"):
		y -= 2
	return Vector2(x,y)

func getRayCast():
	return get_world_2d().get_direct_space_state().intersect_ray(get_pos(),get_pos()+Vector2(0,10),[self])
	
func _fixed_process(dt):
	
	var moveVec = getInput()*maxSpeed
	var colResult = getRayCast()
	apply_impulse(Vector2(0,0),moveVec)
	var vel = get_linear_velocity()
	if vel.x < 0:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)
		
	

	