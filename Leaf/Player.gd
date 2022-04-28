extends Node2D

var tilemap

func _ready():
	pass

var move_cooldown_timer = 0
var move_cooldown = 0.04

func _process(delta):
	if !tilemap:
		return
	if move_cooldown_timer > 0:
		move_cooldown_timer -= delta
		return
	var h = Input.get_axis("ui_left", "ui_right")
	var v = Input.get_axis("ui_up", "ui_down")
	var dir = Vector2(h, v)
	if dir.length_squared() > 0.0:
		var requestedTilePos = tilemap.GetRequestedTilePos(position, dir)
		if tilemap.RequestMove(requestedTilePos):
			Move(requestedTilePos)
		else:
			var horizontal = dir
			var vertical = dir
			horizontal.y = 0
			vertical.x = 0
			horizontal = tilemap.GetRequestedTilePos(position, horizontal)
			vertical = tilemap.GetRequestedTilePos(position, vertical)
			print("cant move ", requestedTilePos, horizontal, vertical)			
			if tilemap.RequestMove(horizontal):
				print("horizontal")
				Move(horizontal)
			elif tilemap.RequestMove(vertical):
				print("vertical")				
				Move(vertical)

func Move(pos):
	position = tilemap.Move(pos)
	move_cooldown_timer += move_cooldown

func RegisterTilemap(tilemap):
	self.tilemap = tilemap
