extends TileMap
const TILE_SIZE = 16
const TILE_BLOCK = 0
const TILE_SLOPE30UP = 3
const TILE_SLOPE45UP = 1
const TILE_SLOPE45DOWN = 2
const TILE_SLOPE30DOWN = 4

func scan_intersecting_tiles(origin,height,delta_x):
	#scans downwards, i.e. assuming the origin of the character's AABB is at the top-left corner.
	var tile_startpos_upper = world_to_map(origin)
	var tile_startpos_lower = world_to_map(origin+Vector2(0,height))
	var tile_endpos_upper = world_to_map(origin+Vector2(delta_x,0))
	var tile_endpos_lower = world_to_map(origin+Vector2(delta_x,height))
	var steps_x = abs(tile_endpos_lower.x - tile_startpos_lower.x)
	var steps_y = tile_endpos_lower.y - tile_endpos_upper.y+1
	if tile_endpos_lower.y == 0:
		steps_y += 1
	var sign_delta = sign(delta_x)
	var tiles = {}
	print(tile_startpos_lower,tile_endpos_lower)
	print("start scan... ", "steps_x: ",steps_x," steps_y: ",steps_y)
	for dx in range(steps_x):
		for dy in range(steps_y):
			var tile_currentpos = tile_startpos_upper + Vector2(sign_delta*dx,dy)
			var tile = get_cellv(tile_currentpos)
			print("tile scanned: ", tile_currentpos, tile)
			if tile != INVALID_CELL:
				if not tiles.has(tile):
					tiles[tile] = []
				tiles[tile].append(map_to_world(tile_currentpos))
	print("end scan")
	return tiles

func _ready():
	pass
func _draw():
	draw_grid()
	pass
func draw_grid():
	var tilemap_height = get_quadrant_size()
	var tilemap_width = get_quadrant_size()
	draw_set_transform(Vector2(-32*8,-32*8), 0, Vector2(16,16))
	var line_color = Color(0,0,1,1)
	for y in range(0, tilemap_height*8):
		draw_line(Vector2(0, y), Vector2(tilemap_width*8, y), line_color)
	for x in range(0, tilemap_width*8):
		draw_line(Vector2(x, 0), Vector2(x, tilemap_height*8), line_color)
