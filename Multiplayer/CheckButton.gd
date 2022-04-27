extends CheckButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _pressed():
	get_node("../IP1").editable = !pressed
	get_node("../IP2").editable = !pressed
	get_node("../IP3").editable = !pressed
	get_node("../IP4").editable = !pressed
