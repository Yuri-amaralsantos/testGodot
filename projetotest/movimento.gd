extends CharacterBody2D


@onready var sprite: Sprite2D = $Sprite2D  # Reference to the sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Reference to the AnimationPlayer
@onready var position2d: Marker2D = $Marker2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_walking: bool = false  # Track if the character is walking
var facing_left: bool = false  # Track the direction the character is facing
var is_attacking: bool = false

		
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
		await animation_player.animation_finished
		is_attacking = false
		return  # Exit to avoid overriding attack animation
	
	
	
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
