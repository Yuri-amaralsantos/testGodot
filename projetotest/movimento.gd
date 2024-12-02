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
    animation_player.animation_finished.connect(_on_animation_finished)
    
func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "attack":  # Verifica se a animação finalizada é a de ataque
        attack_area.monitoring = false  # Desativa a área de ataque
        is_attacking = false

func take_damage(amount: int):
    life -= amount
    
        
    update_life_text()

func update_life_text():
    life_label.text = "Life: %d" % life





func _physics_process(delta: float) -> void:
    # Aplicar gravidade se não estiver no chão
    if not is_on_floor():
        velocity.y += get_gravity().y * delta 

    # Lidar com salto
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY
        animation_player.play("jump")
        return  # Sair para evitar sobrepor a animação de salto

    # Lidar com ataque
    if Input.is_action_just_pressed("fire") and not is_attacking:
        is_attacking = true
        velocity.x = 0  # Parar movimento horizontal durante o ataque
        animation_player.play("attack")
        attack_area.monitoring = true  # Ativar a área de ataque
        return

    # Ignorar movimento se estiver atacando
    if is_attacking:
        return  # Cancelar qualquer outra entrada durante o ataque

    # Lidar com movimento horizontal
    var direction := Input.get_axis("ui_left", "ui_right")
    if Input.is_action_pressed("ui_left"):
        is_walking = true
        animation_player.play("walk")
        velocity.x = direction * SPEED
        position2d.scale.x = 1  # Virar sprite horizontalmente
    elif Input.is_action_pressed("ui_right"):
        is_walking = true
        animation_player.play("walk")
        velocity.x = direction * SPEED
        position2d.scale.x = -1  # Virar sprite horizontalmente
    else:
        velocity.x = 0

    # Atualizar animações de andar
    if direction != 0:
        if direction < 0 and not facing_left:
            facing_left = true
        elif direction > 0 and facing_left:
            facing_left = false

        
    else:
        if is_walking:
            is_walking = false

    # Reproduzir animação de idle se parado e não atacando
    if not is_walking and not is_attacking and is_on_floor() and velocity.y == 0:
        animation_player.play("idle")

    # Mover o personagem
    move_and_slide()



func _on_attack_area_body_entered(body):
    
    if body.name == "inimigo":
        body.take_damage(10)  # Apply damage to the enemy
