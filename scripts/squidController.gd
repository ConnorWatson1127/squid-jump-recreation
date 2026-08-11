extends CharacterBody2D

var isAlive: bool = true
var canMove: bool = true

var maxJumpStrength: float = 6.0
var horizontalAirSpeed: float = 3.0
var maxHAirSpeed: float = 10.0
var jumpChargeRate: float = 0.1
var jumpStrength = 0.0
var sliding: float = .0001

@export var jumpVelocity: float = 200.0
@export var gravity: float = 800.0

@onready var horizontalLock: float = %Camera2D.global_position.x
@onready var jumpSound = load("res://Audio/MGShot00.wav")
@onready var floor_ray_cast: RayCast2D = $floorRayCast

func _physics_process(delta: float) -> void:
	
	if canMove:
		#take jump input
		if Input.is_action_pressed("jumpCharge"):
			jumpStrength += jumpChargeRate
			%AnimationPlayer.play("charge")
			if jumpStrength > maxJumpStrength:
				jumpStrength = maxJumpStrength
				%AnimationPlayer.play("chargeFull")
		
		if Input.is_action_just_released("jumpCharge"):
			if is_on_floor():
				velocity.y = -jumpVelocity * (jumpStrength / 2.5)
				playSFX(jumpSound)
			jumpStrength = 0.0
			%AnimationPlayer.play("idle")
		velocity.y += gravity * delta
		
		#take movement input
		var direction = Input.get_axis("moveLeft", "moveRight")
		if !is_on_floor():
			velocity.x += direction * horizontalAirSpeed
			clampf(velocity.x, -maxHAirSpeed, maxHAirSpeed)
		
		if is_on_floor():
			if onIce():
				velocity.x = lerp(velocity.x, 0.0, sliding)
			else: velocity.x = 0.0
		
		#loop character around screen
		if global_position.x > horizontalLock + 120.0:
			global_position.x = horizontalLock - 120.0
		elif global_position.x < horizontalLock - 120.0:
			global_position.x = horizontalLock + 120.0
		
		move_and_slide()
	%Camera2D.global_position.x = horizontalLock

func playSFX(sfx) -> void:
	%PlayerSFX.set_stream(sfx)
	%PlayerSFX.play()

func onIce():
	var collider = floor_ray_cast.get_collider()
	if not collider: return false
	if collider.name == "iceLayout": 
		return true
	else: 
		return false
