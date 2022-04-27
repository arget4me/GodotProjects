extends KinematicBody2D

export(Vector2) var gravity = Vector2(0.0, 3050.0)

export(float) var maxJumpHeight = 1100
export(float) var walkMaxSpeed = 500
export(Curve) var walkAccelerationCurve

export(float) var runMaxSpeed = 500
export(Curve) var runAccelerationCurve

export(Curve) var jumpAccelerationCurve

var velocity = Vector2(0, 0)
var acceleration = Vector2(0, 0)

var jump = false
var jump_cooldown_timer :float = 0.0
export var jump_cooldown : float = 0.18
export var jump_pitch_timer : float = 0.0

onready var animTree = $AnimationTree
var animStateMachine : AnimationNodeStateMachinePlayback

var LandingParticle = preload("res://LandingParticles.tscn")
onready var LandingParticleSpawn = $ParticleSpawnPosition

onready var JumpSoundPlayer = $JumpSound
onready var LandSoundPlayer = $LandSound
onready var FartSoundPlayer = $FartSound
onready var AttackSoundPlayer = $AttackSound
onready var Attack2SoundPlayer = $AttackSound_Overlay
onready var MusicPlayer = $MusicSound
var pitchShift : int = 0

var attack_timer : float = 5
var attack_cooldown : float = 2.0
var attack : bool = false
var attack_burst_grow : float = 0
var attack_burst_grow_time : float = 0.15
var attackMaxSize : float = 15.0
onready var attackCollider = $AttackShape

var rng = RandomNumberGenerator.new()

func _ready():
	acceleration += gravity
	animStateMachine = animTree.get("parameters/playback")
	animTree.active = true
	$Camera2D.make_current()
	rng.randomize()
	MusicPlayer.play()

func _process(delta):
	if !MusicPlayer.playing:
		MusicPlayer.play()
	
	if attack_timer > 0:
		attack_timer -= delta
	else:
		modulate = Color(0.5, 0.7, 1.0, 0.5)
	
	if !attack:
		if Input.is_action_pressed("attack") && attack_timer <= 0:
			Attack2SoundPlayer.pitch_scale = 1.0 + pitchShift * 0.2
			Attack2SoundPlayer.play()
			AttackSoundPlayer.play()
			if rng.randf_range(0.0, 1.0) < 0.2:
				FartSoundPlayer.pitch_scale = 1.0 + pitchShift * 0.2
				FartSoundPlayer.play()
			
			attack = true
			attack_timer = attack_cooldown
			attack_burst_grow = attack_burst_grow_time
			modulate = Color(1.0, 1.0, 1.0, 1.0)
	elif attack_burst_grow < 0:
		attack = false
		attackCollider.scale = Vector2.ZERO
		attack_burst_grow = 0
	else:
		attack_burst_grow -= delta
		var growPercent = clamp(pow(1.0 - attack_burst_grow / attack_burst_grow_time, 2), 0.0, 1.0)
		var scale = lerp(0, attackMaxSize, growPercent)
		attackCollider.scale = Vector2(scale, scale)
	
	var horizontal_input : float = float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left"))
	horizontal_input += (Input.get_action_strength("axis_right") - Input.get_action_strength("axis_left")) * 2.0
	horizontal_input = clamp(horizontal_input, -1, 1)
	
	velocity.x = lerp(velocity.x, horizontal_input * walkMaxSpeed, 15 * delta)
	if velocity.x < -walkMaxSpeed:
		velocity.x = -walkMaxSpeed
	elif velocity.x > walkMaxSpeed:
		velocity.x = walkMaxSpeed
	
	if jump_cooldown_timer > 0:
		jump_cooldown_timer -= delta
	jump_pitch_timer += delta
	
	if jump_pitch_timer > 1.0:
		pitchShift = 0
	
	var start_jump = false
	if !jump:
		if Input.is_action_pressed("ui_up") && jump_cooldown_timer <= 0:
			animStateMachine.travel("Jumping")
			velocity = Vector2(0, -maxJumpHeight * (1.0 + pitchShift*0.15))
			jump = true
			start_jump = true
			
			JumpSoundPlayer.pitch_scale = 1.0 + pitchShift * 0.05
			JumpSoundPlayer.play()
			pitchShift = (pitchShift + 1) % 5
			jump_pitch_timer = 0
		
	
	if is_on_floor() && !start_jump:
		if jump:
			LandSoundPlayer.pitch_scale = 1.0 + pitchShift * 0.2
			LandSoundPlayer.play()
			
			if rng.randf_range(0.0, 1.0) <= 0.2:
				FartSoundPlayer.pitch_scale = 1.0 + pitchShift * 0.2
				FartSoundPlayer.play()
			jump_cooldown_timer = jump_cooldown
			jump = false
			animStateMachine.travel("Idle")
			var particle = LandingParticle.instance()
			particle.position = position + LandingParticleSpawn.position
			get_tree().current_scene.add_child(particle)
		else:
			velocity.y = 0
	elif velocity.y > 0:
		velocity += 3.5 * acceleration * delta
	else:
		velocity += 1.0 * acceleration * delta
	move_and_slide(velocity, Vector2.UP, true)


func _on_AttackShape_body_entered(body):
	var distanceVector = body.position - position
	var distance = distanceVector.length()
	if distance == 0:
		distanceVector = Vector2.UP
	
	var force_scale = 5000.0 * (1 - clamp(distance / ( attackMaxSize * 32 ), 0, 1))
	
	print(force_scale)
	
	body.apply_impulse(Vector2.ZERO, distanceVector.normalized() * force_scale)
	pass
