extends CharacterBody2D

@onready var attack_area = $AttackArea  # Attack detection area (e.g., Area2D)
var speed = 40
var life = 50  # Enemy's health
@onready var position2d: Marker2D = $Marker2D


@onready var target = $"../Player"

func take_damage(amount: int):
	life -= amount
	if life <= 0:
		die()

func die():
	print("Enemy is dead!")
	queue_free()

func _physics_process(delta: float) -> void:
	# Move towards the player
	if position.x < target.position.x:
		velocity.x = speed
		position2d.scale.x=-1
		
	elif position.x > target.position.x:
		velocity.x = -speed
		position2d.scale.x=1
	else:
		velocity.x = 0

	move_and_slide()




func _on_attacker_area_body_entered(body):
	
	if body.has_method("take_damage"):
		body.take_damage(10)  # Damage the player
