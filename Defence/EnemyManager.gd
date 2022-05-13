extends Control


export(NodePath) var Player : NodePath
export(NodePath) var WalkNodes : NodePath

func _ready():
	for child in get_children():
		var enemy := child as Enemy
		if enemy:
			enemy.RegisterWalkNodes(get_node(WalkNodes))
			enemy.RegisterPlayer(get_node(Player))
