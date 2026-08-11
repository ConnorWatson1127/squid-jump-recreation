extends Node2D

var currentLevelRoot: Node = null
var player: CharacterBody2D = null

@onready var scoreLabel:Label = %scoreLabel
@onready var winSound = load("res://Audio/MGClear00.wav")
@onready var fishSound = load("res://Audio/MGAttack00.wav")

var level: int = 1
var score: int = 0
var timeElapsed: float = 0.0

func _ready() -> void:
	scoreLabel.text = "%s" % score
	currentLevelRoot = get_node("levelRoot")
	loadLevel(level)

# level swapping

func loadLevel(levelNumber: int) -> void:
	if currentLevelRoot:
		currentLevelRoot.queue_free()
	
	# change level
	var levelPath = "res://scenes/levels/level%s.tscn" % levelNumber
	currentLevelRoot = load(levelPath).instantiate()
	add_child(currentLevelRoot)
	currentLevelRoot.name = "levelRoot"
	setupLevel(currentLevelRoot)

func setupLevel(levelRoot: Node) -> void:
	# connect exit
	var exit = levelRoot.get_node_or_null("zapfish")
	if exit:
		exit.body_entered.connect(onExitBodyEntered)
	
	#connect player node reference
	var squid = levelRoot.get_node_or_null("squid")
	if squid:
		player = squid
	
	var fishes = levelRoot.get_node_or_null("fishes")
	if fishes:
		for fish in fishes.get_children():
			fish.body_entered.connect(onFishBodyEntered)
	
	%messageLabel.visible = false
	timeElapsed = 0.0

#connected signals

func onExitBodyEntered(body: Node2D) -> void:
	if body.name == "squid":
		body.canMove = false
		%messageLabel.text = "Level %s Clear!\nClear Bonus: 500\nTime Bonus: %s" % [level, timeBonus(timeElapsed)]
		
		#change level and add score
		level += 1
		score += 500 + timeBonus(timeElapsed)
		scoreLabel.text = "%s" % score
		
		#play win sfx
		body.playSFX(winSound)
		
		%messageLabel.visible = true
		%transitionTimer.start()

func onFishBodyEntered(body: Node2D) -> void:
	if body.name == "squid":
		body.velocity.y = -800.0
		body.playSFX(fishSound)



func _physics_process(delta: float) -> void:
	timeElapsed += delta
	%musicPlayer.global_position = player.global_position
	%timeLabel.text = str(int(timeElapsed))

func _on_timer_timeout() -> void:
	call_deferred("loadLevel", level)

func timeBonus(t: float) -> int:
	if t < 15:
		return 300
	else:
		return 300 - int((t - 15.0) * 4)
