extends Spatial

export var Width : int = 3
export var Height : int = 3
export(Resource) var PillarType

func _ready():
	var Pillars = load(PillarType.get_path())
	for y in range(Height):
		for x in range(Width):
			var p = Pillars.instance()
			p.translation.x = 0.5 * (float(x) - float(Width - 1)/2.0)
			p.translation.z = 0.5 * (-float(y) + float(Height - 1)/2.0)
			add_child(p)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#var started = false
#onready var p1 = $Player
#onready var p2 = $Player2
#func _process(delta):
#	if !started && (Input.is_action_pressed("jump") || Input.is_action_pressed("jump2")):
#		started = true
#		p2.start()
#		p1.start()
		
		
