extends CharacterBody2D

enum PlayerState{
	idle,
	walk,
	jump,
	fall,
	duck,
	slide,
	dead
}

@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var max_speed = 180.0
@export var acceleration = 400
@export var deceleration = 400
@export var slide_deceleration = 100
const JUMP_VELOCITY = -300.0

var jump_count = 0 
@export var max_jump_count = 2              #limitar o número de pulo
var direction = 0 
var status: PlayerState


func _ready() -> void:
	go_to_idle_state()


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta              #add gravidade
	
	match status: 
		PlayerState.idle: 
			idle_state(delta)
		PlayerState.walk: 
			walk_state(delta)
		PlayerState.jump: 
			jump_state(delta)
		PlayerState.fall: 
			fall_state(delta)
		PlayerState.duck: 
			duck_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.dead:
			dead_state(delta)
			
	move_and_slide()

#Implementando as funções de transição de estado
func go_to_idle_state():
	status = PlayerState.idle
	anima.play("idle")
	
func go_to_walk_state(): 
	status = PlayerState.walk
	anima.play("walk")
	
func go_to_jump_state(): 
	status = PlayerState.jump
	anima.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1 
	
func go_to_fall_state(): 
	status = PlayerState.fall
	anima.play("fall")
	
#Implementando as funções de estado 
func go_to_duck_state(): 
	status = PlayerState.duck
	anima.play("duck")
	set_small_collider()

func exit_from_duck_state():   #Encerrando o estado de abaixar
	set_large_collider()               
	
func go_to_slide_state():
	status = PlayerState.slide
	anima.play("slide")
	set_small_collider()
	
func exit_from_slide_state():
	set_large_collider()
	
func go_to_dead_state():
	status = PlayerState.dead
	anima.play("dead")
	velocity = Vector2.ZERO
		
func idle_state(delta):
	move(delta)
	if velocity.x != 0: 
		go_to_walk_state()
		return 
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return
	
func walk_state(delta):
	move(delta)
	if velocity.x == 0: 
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_just_pressed("duck"):
		go_to_slide_state()
	
	if !is_on_floor():              #se ele não está no chão
		jump_count += 1 
		go_to_fall_state()
		return
		
func jump_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
		
	if velocity.y > 0: 
		go_to_fall_state()
		return
		
func fall_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
		
	if is_on_floor():                   #verificando se está no chão
		jump_count = 0                  #zerando o contador de pulo para pular quando sair do chão 
		if velocity.x == 0:
			go_to_idle_state()
		else: 
			go_to_walk_state()
		return
		
func duck_state(_delta):
	update_direction()
	if Input.is_action_just_released("duck"):              #receber a ação de se recuperar do estado abaixar
		exit_from_duck_state()                            #executar o fim do estado
		go_to_idle_state()                               #transição pro estado parado
		return

func slide_state(delta):
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_slide_state()
		go_to_walk_state()
		return
		
	if velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()
		return
	
func dead_state(_delta):
	pass

func move(delta):
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		
func update_direction():
	direction = Input.get_axis("left", "right")
	
	if direction < 0:
		anima.flip_h = true
	elif direction > 0: 
		anima.flip_h = false
		
func can_jump() -> bool:                            #método de pode pular para limitar o número de pulos
	return jump_count < max_jump_count              #retornar true se o contador for menor que o máximo definido 
	
func set_small_collider():                   #diminuindo o colisor para quando abaixar
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
func set_large_collider():                  #aumentando o colisor
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	
func _on_hitbox_area_entered(area: Area2D) -> void:         #verificar se entrou em contato com o inimigo
	var enemy = area.get_parent()
	if enemy.has_method("take_damage"):
		if velocity.y > 0: 
		#inimigo morre
			area.get_parent().take_damage()
			go_to_jump_state()
		else: 
			if status != PlayerState.dead:
				go_to_dead_state()
			#player morre
		