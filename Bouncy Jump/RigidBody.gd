extends RigidBody

class_name Player
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity = 0

var SurfaceMaterial
export var color = Color(1, 0, 0, 1)
export var jumpAxis = "jump"
export var downAxis = "ui_down"
export var upAxis = "ui_up"
export var leftAxis = "ui_left"
export var rightAxis = "ui_right"
onready var meshInstance = $MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	SurfaceMaterial = meshInstance.mesh.surface_get_material(0)
	SurfaceMaterial.set_albedo(color)
	gravity = gravity_scale
	gravity_scale = 0

var jumping = false;
var jump = false;



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gravity_scale == 0:
		if Input.is_action_pressed(jumpAxis):
			gravity_scale = gravity
		return
	
	if Input.is_action_pressed(downAxis):
		add_force(Vector3(0, 0, 10)*delta, Vector3.ZERO)
	if Input.is_action_pressed(upAxis):
		add_force(Vector3(0, 0, -10)*delta, Vector3.ZERO)
	if Input.is_action_pressed(leftAxis):
		add_force(Vector3(-10, 0, 0)*delta, Vector3.ZERO)
	if Input.is_action_pressed(rightAxis):
		add_force(Vector3(10, 0, 0)*delta, Vector3.ZERO)
	if !jumping && Input.is_action_just_pressed(jumpAxis):
		jump = true
		jumping = true

func start():
	gravity_scale = gravity
	
var elapsed = 0.0
var reset_state = false
var bump = false
func _integrate_forces(state):
	if reset_state:
		var t = state.get_transform()   
		linear_velocity = Vector3(0, -7, 0)
		t.origin.x = 0  
		t.origin.y =  2
		t.origin.z = 0
		reset_state = false
		state.set_transform(t)
	if jump:
		jump = false
		linear_velocity = Vector3(0, 6, 0)
	if bump:
		bump = false
		linear_velocity = Vector3(0, 4.5, 0)


func reset_jump():
	bump = true
	jumping = false
