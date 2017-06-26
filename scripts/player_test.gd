extends Node2D
### Nodes ###
onready var tilemap = get_parent().get_node("TileMap")

### Member Variables ###
const TILE_SLOPE_45_UP= 9
const TILE_SLOPE_45_DOWN = 10
const TILE_SIZE = 16
const TILE_BLOCK = 1
const WALK_SPEED = 5
var sprite_extents = Vector2(TILE_SIZE,2*TILE_SIZE) #1-Tile Wide, 2 Tiles Tall

### Input Functions ###

### Movement Functions ###
func handle_horizontal_movement():
	#The Origin of The Kinematic Character is at the top-left corner of the AABB with sprite_extents
	var delta_x = 0
	var input_left = Input.is_action_pressed("left")
	var input_right = Input.is_action_pressed("right")
	var forward_position_at_head = get_pos()
	if input_left:
		delta_x += -WALK_SPEED
		forward_position_at_head.x -= sprite_extents.x
	if input_right:
		delta_x += WALK_SPEED + sprite_extents.x #add this to delta_x to not check the tile we are already in
		forward_position_at_head.x += sprite_extents.x
	if delta_x != 0:
		print("current tile pos at head: ",tilemap.world_to_map(get_pos()))
		var tiles = tilemap.scan_intersecting_tiles(forward_position_at_head,sprite_extents.y,delta_x)
		if not tiles.empty():
			handle_horizontal_collision(tiles,delta_x)
		else:
			translate(Vector2(sign(delta_x)*WALK_SPEED,0))
		
### Collision Functions ###
func handle_horizontal_collision(tiles,delta_x):
	var walls = []
	for key in tiles.keys():
		print(key)
	if tiles.has(TILE_BLOCK):
		walls = tiles[TILE_BLOCK]
		walls.sort()
	if delta_x > 0 and not walls.empty():
		set_pos(Vector2(walls[0].x-sprite_extents.x,get_pos().y))
	elif delta_x < 0 and not walls.empty():
		set_pos(Vector2(walls[-1].x+sprite_extents.x,get_pos().y))
	pass
	
### FIXED PROCESS ###
func _fixed_process(dt):
	handle_horizontal_movement()
	pass
	
### DRAWING ###
func _draw():
	draw_rect(Rect2(0,0,sprite_extents.x,sprite_extents.y),Color(1,0,0,1))
	pass
	
func _ready():
	set_fixed_process(true)
	pass
