extends Spatial

onready var PillarMesh : MeshInstance = $PillarMesh
var BaseY : float
export var WobbleScale = 0.2
export var WobbleSpeed = 1.9
var Elapsed : float = 0.0
var SurfaceMaterial
var myseed
var posFromCenter
var maxHeight
var StartBaseColor : Color
var BaseColor : Color

func _ready():
	BaseY = translation.y
	SurfaceMaterial = PillarMesh.mesh.surface_get_material(0)
	posFromCenter = Vector2(translation.x, translation.z).length()
	maxHeight = (WobbleScale + posFromCenter * 0.05)
	StartBaseColor = SurfaceMaterial.get_albedo()
	BaseColor = StartBaseColor
	
func _physics_process(delta):
	Elapsed += delta
	translation.y = BaseY - (1.0 + cos(WobbleSpeed * Elapsed + PI + posFromCenter*PI/4)) / 2.0 * maxHeight
	SurfaceMaterial.set_albedo(BaseColor * (0.8 + 0.2 * translation.y / maxHeight))
#	if randf() < 0.01:
#		Toggle()

func Toggle(color : Color):
	if BaseColor == StartBaseColor:
		BaseColor = color
	else:
		BaseColor = StartBaseColor
	


func _on_Area_body_entered(body):
	if body is Player:
		var b = body as Player
		b.reset_jump()
		Toggle(b.color)
