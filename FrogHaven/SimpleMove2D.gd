extends Sprite

export var speed : float = 1.0

func _ready():
	pass

func _process(delta):
	position.x += speed * (float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left"))) * delta
	position.y += speed * (float(Input.is_action_pressed("ui_down")) - float(Input.is_action_pressed("ui_up"))) * delta
	
