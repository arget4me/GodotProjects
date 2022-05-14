extends MeshInstance

var NewMesh = Mesh.new()
var Vertices = PoolVector3Array()
var UVs = PoolVector2Array()
var SpatialMat = SpatialMaterial.new()
onready var music = $AudioStreamPlayer
export(Vector3) var bounds = Vector3(1.0, 1.0, 1.0)

func AddPlane(Origin : Vector3, Normal : Vector3, Size : Vector2 = Vector2.ONE, Offset : float = 0, UP : Vector3 = Vector3.UP):
	var Tangent : Vector3
	var Bitangent : Vector3
	Normal = Normal.normalized()
	Origin += Normal * Offset
	
	Tangent = Normal.cross(UP)
	Bitangent = Normal.cross(Tangent)
	Tangent *= Size.x
	Bitangent *= Size.y
	
	#Top Triangle
	Vertices.push_back(Origin - Tangent * 0.5 + Bitangent * 0.5)
	UVs.push_back(Vector2(0, 1))
	
	
	Vertices.push_back(Origin + Tangent * 0.5 + Bitangent * 0.5)
	UVs.push_back(Vector2(1, 1))
	
	
	Vertices.push_back(Origin - Tangent * 0.5 - Bitangent * 0.5)
	UVs.push_back(Vector2(0, 0))
	
	#Bottom Triangle
	Vertices.push_back(Origin - Tangent * 0.5 - Bitangent * 0.5)
	UVs.push_back(Vector2(0, 0))
	
	
	Vertices.push_back(Origin + Tangent * 0.5 + Bitangent * 0.5)
	UVs.push_back(Vector2(1, 1))
	
	
	Vertices.push_back(Origin + Tangent * 0.5 - Bitangent * 0.5)
	UVs.push_back(Vector2(1, 0))

func AddCube(Origin : Vector3, Bounds : Vector3):
	AddPlane(Origin, Vector3(0, 0, 1), Vector2(Bounds.z, Bounds.y), Bounds.x / 2)
	AddPlane(Origin, Vector3(0, 0, -1), Vector2(Bounds.z, Bounds.y), Bounds.x / 2)
	AddPlane(Origin, Vector3(0, -1, 0), Vector2(Bounds.x, Bounds.z), Bounds.y / 2, Vector3.LEFT)
	AddPlane(Origin, Vector3(0, 1, 0), Vector2(Bounds.x, Bounds.z), Bounds.y / 2, Vector3.LEFT)
	AddPlane(Origin, Vector3(1, 0, 0), Vector2(Bounds.x, Bounds.y), Bounds.z / 2)
	AddPlane(Origin, Vector3(-1, 0, 0), Vector2(Bounds.x, Bounds.y), Bounds.z / 2)
#	

func _ready():
	AddCube(Vector3(0, 0, 0), Vector3(3,2,4))
	AddCube(Vector3(3, 2, -3), Vector3(3,2,4))
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for v in Vertices.size():
		var vv = (Vertices[v] + Vector3(1, 1, 1)) / 4
		st.add_color(Color(vv.x + 0.25, vv.y + 0.25, vv.z + 0.25, 1))
		st.add_uv(UVs[v])
		st.add_vertex(Vertices[v])

	st.commit(NewMesh)

	mesh = NewMesh

func _process(delta):
	rotate_x(0.1 * delta)
	rotate_y(delta)
	rotate_z( 0.7* delta)
	pass
