extends CharacterBody2D


@onready var sprite: Sprite2D = $Sprite2D  # Reference to the sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Reference to the AnimationPlayer

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_walking: bool = false  # Track if the character is walking

func _physics_process(delta: float) -> void:
	# Add gravity if not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle horizontal movement (left and right)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		# Start walking animation when character starts moving
		if not is_walking:
			is_walking = true
			animation_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		# Stop walking animation when character stops moving
		if is_walking:
			is_walking = false
			animation_player.stop()

	# Move the character
	move_and_slide()
