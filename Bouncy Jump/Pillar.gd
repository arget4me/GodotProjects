extends Spatial

onready var PillarMesh : MeshInstance = $PillarMesh
var BaseY : float
export var WobbleScale = 0.2
export var WobbleSpeed = 1.9
var Elapsed : float = 0.0
var SurfaceMaterial
var myseed
func _ready():
	BaseY = PillarMesh.translation.y
	SurfaceMaterial = PillarMesh.mesh.surface_get_material(0)
	
func _process(delta):
	Elapsed += delta
	PillarMesh.translation.y = BaseY - (1.0 + cos(WobbleSpeed * Elapsed + PI)) / 2.0 * WobbleScale
	if randf() < 0.01:
		Toggle()

func Toggle():
	if SurfaceMaterial.get_albedo() == Color(1, 0, 0, 1):
		SurfaceMaterial.set_albedo(Color(1, 1, 0, 1))
	else:
		SurfaceMaterial.set_albedo(Color(1, 0, 0, 1))
	
