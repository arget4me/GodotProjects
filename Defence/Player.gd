extends KinematicBody2D

var momentum = Vector2.ZERO
var speed = 250
var acceleration = 25

func _physics_process(delta):
	var horizontal = clamp(Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"), -1, 1)
	var vertical = clamp(Input.get_action_strength("DOWN") - Input.get_action_strength("UP"), -1, 1)
	momentum = lerp(momentum, Vector2(horizontal, vertical).normalized() * speed, delta * acceleration)
	
	move_and_slide(momentum)
