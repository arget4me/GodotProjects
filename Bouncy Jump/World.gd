extends Spatial

export var Width : int = 3
export var Height : int = 3
export(Resource) var PillarType

func _ready():
	var Pillars = load(PillarType.get_path())
	for y in range(Height):
		for x in range(Width):
			var p = Pillars.instance()
			p.translation.x = 0.5 * (float(x)- float(Width - 1)/2.0)
			p.translation.z = 0.5 * (-float(y))
			add_child(p)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
