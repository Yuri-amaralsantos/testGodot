extends CharacterBody2D

@onready var sprite: Sprite2D = $Marker2D/Sprite2D   # Reference to the sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Reference to the AnimationPlayer
@onready var position2d: Marker2D = $Marker2D  # Marker for attack direction
@onready var attack_area = $Marker2D/AttackArea # Attack detection area (e.g., Area2D)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_walking: bool = false  # Track if the character is walking
var facing_left: bool = false  # Track the direction the character is facing
var is_attacking: bool = false
var life = 100  # Player's health
@onready var life_label = $Camera2D/Label # Reference to the Label node

func _ready():
	update_life_text()

func take_damage(amount: int):
	life -= amount
	
		
	update_life_text()

func update_life_text():
	life_label.text = "Life: %d" % life





func _physics_process(delta: float) -> void:
	
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += get_gravity().y * delta 

	# Handle jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("jump")
		return  # Exit to avoid overriding jump animation

	# Handle attack
	if Input.is_action_just_pressed("fire") and not is_attacking:
		is_attacking = true
		animation_player.play("attack")
		velocity.x = 0
		attack_area.monitoring = true  # Enable attack area
		await animation_player.animation_finished
		attack_area.monitoring = false  # Disable attack area
		is_attacking = false
		return
	
	
	
	# Handle horizontal movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_action_pressed("ui_left"):
		velocity.x = direction * SPEED
		position2d.scale.x=1  # Flip the sprite horizontally
		
	elif Input.is_action_pressed("ui_right"):
		velocity.x = direction * SPEED
		position2d.scale.x=-1  # Flip the sprite horizontally
	else:
		velocity.x = 0
	
	if direction != 0:
		velocity.x = direction * SPEED
		# Update facing direction
		if direction < 0 and not facing_left:
			facing_left = true
			
		elif direction > 0 and facing_left:
			facing_left = false

		# Play walking animation
		if not is_walking and is_on_floor() and not is_attacking:
			is_walking = true
			animation_player.play("walk")
	else: # Smoothly decelerate
		if is_walking:
			is_walking = false
	
	# Play idle animation if not moving, attacking, or jumping
	if not is_walking and not is_attacking and is_on_floor() and velocity.y == 0:
		animation_player.play("idle")

	# Move the character
	move_and_slide() 



func _on_attack_area_body_entered(body):
	
	if body.name == "inimigo":
		body.take_damage(10)  # Apply damage to the enemy
