extends KinematicBody2D

const TILE_45DOWN = 10
const TILE_45UP = 9
const TILE_SIZE = 16.0
const RAYCAST_MAX_LENGTH = 8

var maxSpeed = 100 #has to be an integer for movement to be precise.

onready var tileMap = get_parent().get_node("TileMap")

func _ready():
	set_fixed_process(true)
	
func getInput():
	var x = 0
	if Input.is_action_pressed("left"):
		x-= 1
	if Input.is_action_pressed("right"):
		x+= 1
	return x

func getRayCast():
	return get_world_2d().get_direct_space_state().intersect_ray(get_pos(),get_pos()+Vector2(0,16),[self])
	
func _fixed_process(dt):
	
	var deltaX = getInput()
	var colResult = getRayCast()
	if deltaX != 0:
		if not colResult.empty():
			var currentX = get_pos().x
			print("Current X: " + str(currentX)," Final X: " + str(currentX + deltaX*maxSpeed))
			var currentTileCoord = tileMap.world_to_map(colResult.position)
			var currentTileIndex = tileMap.get_cellv(currentTileCoord)
			var futureTileCoord = tileMap.world_to_map(colResult.position+Vector2(deltaX,0)*maxSpeed)
			var tileDeltaX = futureTileCoord.x - currentTileCoord.x
			print("Tiles crossed: " + str(tileDeltaX))
			if tileDeltaX != 0:
				var remainingX = abs(deltaX)
				for x in range(abs(tileDeltaX)):
					if remainingX > 0:
						var deltaY = 0
						if currentTileIndex == TILE_45DOWN:
							deltaY = 1
						elif currentTileIndex == TILE_45UP:
							deltaY = -1
						var endPosOfCurrentTileX = tileMap.map_to_world(currentTileCoord).x+sign(deltaX)*(TILE_SIZE)
						var deltaAlongCurrentTileX = endPosOfCurrentTileX - currentX
						var remainder = move(deltaAlongCurrentTileX*Vector2(1,deltaY))
						if remainder != Vector2(0,0):
							print("Collided along the way!")
							break
						remainingX -= abs(deltaAlongCurrentTileX)
						currentTileCoord.x += 1*sign(deltaX)
						currentTileIndex = tileMap.get_cellv(currentTileCoord)
					else:
						print("Finished Movement")
			else:
				var deltaY = 0
				if currentTileIndex == TILE_45DOWN:
					deltaY = 1
				elif currentTileIndex == TILE_45UP:
					deltaY = -1
				move(deltaX*Vector2(1,deltaY))
			print("Pos after movement : " +str(get_pos().x))
	

	