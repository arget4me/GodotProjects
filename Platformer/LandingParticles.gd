extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var RightParticle = $Particles2DRight
onready var LeftParticle = $Particles2DLeft
# Called when the node enters the scene tree for the first time.
func _ready():
	RightParticle.emitting = true
	LeftParticle.emitting = true


func _process(delta):
	#if RightParticle.emitting == false:
	#	queue_free()
	pass
