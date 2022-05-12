extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity = Vector2(0.0, 1000)
var velocity = Vector2.ZERO
var speed = 750
var acc = 5
var horizontalAxis = Vector2(1, 0)
var jump : bool = false
onready var camera = $Camera2D
onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.make_current()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var horizontal = speed * (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	velocity += gravity * delta * (1 + 4 * Input.get_action_strength("ui_down")) * float(!is_on_floor())
	
	var horizontalVel = lerp(velocity.dot(horizontalAxis.normalized()), horizontal, delta * acc) * horizontalAxis
	var verticalVel = velocity - velocity.dot(horizontalAxis.normalized()) * horizontalAxis
	
	if Input.get_action_strength("ui_up"):
		verticalVel = lerp(verticalVel, -gravity * 1, delta * 10)
	
	velocity = verticalVel + horizontalVel
	
	sprite.set_flip_h(velocity.dot(horizontalAxis.normalized()) > 0)
		
	
	move_and_slide(velocity)
