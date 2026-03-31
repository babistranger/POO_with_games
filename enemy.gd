extends CharacterBody2D

enum enemy {
	walk, 
	receive_damage,
	dead
}

@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var health_bar: TextureProgressBar = $CanvasLayer/health_bar
@onready var status_label: Label = $CanvasLayer/StatusLabel

const SPEED = 10.0
const JUMP_VELOCITY = -400.0

var status: enemyState
var direction = 1
@export var max_health = 3.0 
var _health = 0.0              # O símbolo antes da variável torna ela privada em godot


func _ready() -> void:
	_health = max_health
	health_bar.max_value = max_health
	health_bar.value = _health
	go_to_walk_state()

func _physics_process(delta: float) -> void:          #Implementar os processos físicos
	
	if not is_on_floor():
		velocity += get_gravity() * delta           #add gravidade 
		
	match status:                                 #implementando uma máquina de estados finitos
		enemyState.walk:                        #estado para o inimigo patrulhar
			walk_state(delta)
		enemyState.receive_damage:             #estado ser atacado
			receive_damage_state()
		enemyState.dead:                      #estado ser morto
			dead_state(delta)
			
	move_and_slide()
			
func go_to_walk_state():                            #estado de transição para o inimigo patrulhar
	status = enemyState.walk
	anima.play("walk")
	
func go_to_receive_damage_state():
	status = enemyState.receive_damage
	anima.play("hit") 
	#fazendo knockback
	velocity.x = -direction * 50
	velocity.y = -100

func go_to_dead_state(): 
	status = enemyState.dead
	anima.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED     #Matar também o colisor de área de "ataque"
	velocity = Vector2.ZERO
	
func walk_state(_delta):                      
	move()                                       #aplicando polimorfismo
	
	if wall_detector.is_colliding():             #função de andar para patrulhar um território verificando o limite de parede
		scale.x *= -1 
		direction *= -1 
		
	if not ground_detector.is_colliding():      #patrulhando um território, verificando o limite de piso para não cair aleatoriamente
		scale.x *= -1 
		direction *= -1 
		
func move():
	velocity.x = SPEED * direction

func receive_damage_state():                  #Função para o estado de receber dano
	if not anima.is_playing():
		if _health > 0:
			go_to_walk_state()
		else:
			go_to_dead_state()

func dead_state(_delta): 
	pass 
	
func take_damage(damage = 1):           #O método que modifica a saúde do inimigo (impõe dano ao inimigo)
	if status == enemyState.dead:      #Verificando se o inimigo não está morto 
		return
	health_bar.visible = true       #A barra de saúde só aparece quando toma dano
	health_bar.value = _health        
	_health -= damage
	if _health > 0:
		go_to_receive_damage_state()
	else:
		go_to_dead_state()     #vai pro estado de morto 

func display_status():                #Função para mostrar o status do inimigo
	var state_text = ""

	match status:
		enemyState.walk:
			state_text = "WALK"
		enemyState.receive_damage:
			state_text = "HIT"
		enemyState.dead:
			state_text = "DEAD"

	status_label.text = "HP: %d | State: %s | Dir: %d" % [_health, state_text, direction]      #HP - quantas vidas tem, state, que estado está, direção