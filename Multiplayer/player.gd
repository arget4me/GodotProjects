extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var localPlayer = false
var speed = 250
var selfPeerID = -1
var started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not localPlayer || not started:
		return
		
	if Input.is_action_pressed("move_right"):
		position.x += speed * delta
	if Input.is_action_pressed("move_left"):
		position.x -= speed * delta
	if Input.is_action_pressed("move_up"):
		position.y -= speed * delta
	if Input.is_action_pressed("move_down"):
		position.y += speed * delta
	
	if Input.is_action_pressed("rotate_left"):
		rotation_degrees -= speed * delta
	if Input.is_action_pressed("rotate_right"):
		rotation_degrees += speed * delta
	
	rpc_unreliable("SetTransform", position, rotation_degrees)

func LocalPlayer():
	localPlayer = true

remote func SetTransform(pos, rot):
	position = pos
	rotation_degrees = rot

func SetDisplayName(name):
	print("SetPlayerName")
	get_node("Name").text = name 
