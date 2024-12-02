extends CharacterBody2D

@onready var attack_area = $AttackArea  
@onready var position2d: Marker2D = $Marker2D
@onready var target = $"../Player"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var speed = 70
var life = 50  # Enemy's health
var attack_range = 200


func take_damage(amount: int):
	life -= amount
	if life <= 0:
		die()

func die():
	print("Enemy is dead!")
	queue_free()

func _physics_process(delta: float) -> void:
	# Verifica se o jogador é válido
	if target and target.is_inside_tree():
		var distance_to_target = position.distance_to(target.position)

		# Move apenas se estiver fora do alcance de ataque
		if distance_to_target > attack_range:
			var direction = (target.position - position).normalized()
			velocity.x = direction.x * speed
			animation_player.play("idle")
			# Ajusta a direção visual do inimigo
			position2d.scale.x = direction.x*-1
		else:
			var direction = (target.position - position).normalized()
			
			animation_player.play("attack")
			

		# Movimenta o inimigo
		move_and_slide()
	else:
		velocity = Vector2.ZERO  # Para de se mover caso o jogador não exista




func _on_attacker_area_body_entered(body):
	
	if body.has_method("take_damage"):
		body.take_damage(10)  # Damage the player
