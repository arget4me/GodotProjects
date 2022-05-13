extends KinematicBody2D

class_name Enemy

var WalkNodesParent
var PlayerReference

	
func RegisterWalkNodes(walkNodesParent):
	WalkNodesParent = walkNodesParent
	
func RegisterPlayer(player):
	PlayerReference = player
	
var momentum = Vector2.ZERO
var speed = 200
var acceleration = 12

var findNextNodeCooldown = 1.8
var findNextNodeTimer = 0.0

var CurrentWalkNode : Node2D
var PreviousNodes : Array
var PreviousNodesMaxSize = 6
var PreviousNodesIndex = 0

var shouldForceNewNode = false

func _ready():
	for i in range(PreviousNodesMaxSize):
		PreviousNodes.append(null)

func CanProcess():
	return WalkNodesParent && PlayerReference

func FindNextWalkNode(forceDirectionChange = false):
	if not CanProcess():
		return
	
	var newClosest : Node2D
	var closestDistanceSq : float = 1.79769e308 # Double approx max value since godot floats use double-precision floating-point numbers
	for node in WalkNodesParent.get_children():
		if node as Node2D:
			if not forceDirectionChange:
				if randf() < 0.01:
					newClosest = node as Node2D
					break
				
				var is_previous = false
				for prev in PreviousNodes:
					if prev == node:
						is_previous = true
						break
				if is_previous:
					continue
			
			var directionVector = node.global_position - position
			var distanceSq = directionVector.length_squared()
			
			if forceDirectionChange && momentum.normalized().dot(directionVector.normalized()) > -0.1:
				continue
			
			if distanceSq < closestDistanceSq:
				closestDistanceSq = distanceSq
				newClosest = node as Node2D
			
	PreviousNodes[PreviousNodesIndex] = CurrentWalkNode
	PreviousNodesIndex = (PreviousNodesIndex + 1) % PreviousNodesMaxSize
	CurrentWalkNode = newClosest
	return

func _process(delta):
	if not CanProcess():
		return
	if shouldForceNewNode:
		FindNextWalkNode(true)
		findNextNodeTimer = findNextNodeCooldown
		if CurrentWalkNode:
			shouldForceNewNode = false
			print("Target ", CurrentWalkNode, CurrentWalkNode.global_position, " MomentumNorm: ", momentum.normalized())
		else:
			print("couldn't find target")
	else:
		findNextNodeTimer -= delta
		if findNextNodeTimer <= 0.0 && momentum.length_squared() < 50000:
			findNextNodeTimer += findNextNodeCooldown
			FindNextWalkNode()
	

func _physics_process(delta):
	if not CanProcess():
		return
	
	var playerDirectionVector = PlayerReference.position - position
	var nodeDirectionVector = Vector2.ZERO

	var TargetBlend = Vector2(1.0, 0.0)
	if CurrentWalkNode && playerDirectionVector.length_squared() > 25000:
		nodeDirectionVector = CurrentWalkNode.global_position - position
		if nodeDirectionVector.length_squared() > 5:
			TargetBlend = Vector2(0.0, 1.0)
		else:
			TargetBlend = Vector2(0.0, 0.0)
	
	var directionVectorNormalized = ( TargetBlend.x * playerDirectionVector + TargetBlend.y * nodeDirectionVector ).normalized()
	momentum = lerp(momentum, directionVectorNormalized * speed, delta * acceleration)
	
	move_and_slide(momentum)


func _on_collide_with_static(body):
	shouldForceNewNode = true
	print("Enter ", body.get_name())
func _on_stop_collide_with_static(body):
	shouldForceNewNode = false
	print("Exit ", body.get_name())
