extends Node2D
### Nodes ###
onready var tilemap = get_parent().get_node("map/TileMap")
onready var sprite = get_node("Sprite")

### Member Variables ###
const WALK_SPEED = 3
onready var sprite_extents = Vector2(tilemap.TILE_SIZE,2*tilemap.TILE_SIZE) #1-Tile Wide, 2 Tiles Tall

### Input Functions ###

### Movement Functions ###
func handle_horizontal_movement():
	#The Origin of The Kinematic Character is at the top-left corner of the AABB with sprite_extents
	var dir = 0
	var input_left = Input.is_action_pressed("left")
	var input_right = Input.is_action_pressed("right")
	var space = get_world_2d().get_direct_space_state()
	var total_translate = Vector2(0,0)
	var forward_pos = Vector2(get_pos().x+sprite_extents.x/2,get_pos().y+sprite_extents.y+1)
	if input_left:
		dir -= 1
		sprite.set_flip_h(true)
	if input_right: 
		dir += 1
		sprite.set_flip_h(false)
	if dir != 0:
		var tile_at_feet
		for dx in range(WALK_SPEED):
			tile_at_feet = tilemap.get_cellv(tilemap.world_to_map(forward_pos+total_translate))
			#var tile_at_feet_forward = tilemap.get_cellv(tilemap.world_to_map(Vector2(get_pos().x+sign(delta_x*sprite_extents.x,get_pos().y+sprite_extents.y)))
			print(tile_at_feet)
			if tile_at_feet == tilemap.TILE_BLOCK:
				total_translate += Vector2(dir,0)
			elif tile_at_feet == tilemap.TILE_SLOPE45UP:
				total_translate += Vector2(dir,-dir)
			elif tile_at_feet == tilemap.TILE_SLOPE30UP:
				total_translate += Vector2(dir,-0.5*dir)
			elif tile_at_feet == tilemap.TILE_SLOPE30DOWN:
				total_translate += Vector2(dir,dir)
			elif tile_at_feet == tilemap.TILE_SLOPE45DOWN:
				total_translate += Vector2(dir,dir)
		
		translate(Vector2(total_translate.x,total_translate.y))
		print(forward_pos)
	
### Collision Functions ###
### FIXED PROCESS ###
func _fixed_process(dt):
	handle_horizontal_movement()
	pass
	
### DRAWING ###
func _draw():
	#draw_rect(Rect2(0,0,sprite_extents.x,sprite_extents.y),Color(1,1,0,1))
	pass
	
func _ready():
	set_fixed_process(true)
	pass
