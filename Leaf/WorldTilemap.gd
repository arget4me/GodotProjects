extends TileMap

func _ready():
	for x in self.get_used_cells():
		if get_cellv(x) == 2:
			set_cellv(x, 0)
			var actor = preload("res://Actor.tscn").instance()
			actor.RegisterTilemap(self)
			Instantiate(actor, x)
		if get_cellv(x) == 3:
			set_cellv(x, 0)
			Instantiate(preload("res://Entity.tscn").instance(), x)
			

func Instantiate(type : Node2D, pos : Vector2):
	type.position = map_to_world(pos, false)
	add_child(type)

func GetRequestedTilePos(worldpos : Vector2, direction : Vector2) -> Vector2:
	var tilepos = world_to_map(worldpos)
	var tileoffset = Vector2(int(direction.x), int(direction.y))
	return tilepos + tileoffset

func RequestMove(requestedTilePos : Vector2) -> bool:
	return get_cellv(requestedTilePos) == 0

func Move(requestedTilePos : Vector2) -> Vector2:
	return map_to_world(requestedTilePos)
