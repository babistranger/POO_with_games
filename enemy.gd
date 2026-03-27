extends CharacterBody2D

enum BigRedState {
	walk, 
	receive_damage,
	dead
}

@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector

const SPEED = 10.0
const JUMP_VELOCITY = -400.0

var status: BigRedState
var direction = 1
@export var max_health = 3
var health = 3


func _ready() -> void:
	health = max_health
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity = get_gravity() * delta
		
	match status: 
		BigRedState.walk:
			walk_state(delta)
		BigRedState.receive_damage:
			receive_damage_state(delta)
		BigRedState.dead: 
			dead_state(delta)
			
	move_and_slide()
			
func go_to_walk_state(): 
	status = BigRedState.walk
	anima.play("walk")
	
func go_to_receive_damage_state():
	status = BigRedState.receive_damage
	anima.play("hit") 
	#fazendo knockback
	velocity.x = -direction * 50
	velocity.y = -100

func go_to_dead_state(): 
	status = BigRedState.dead
	anima.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	
func walk_state(_delta): 
	velocity.x = SPEED * direction
	
	if wall_detector.is_colliding():
		scale.x *= -1 
		direction *= -1 
		
	if not ground_detector.is_colliding():
		scale.x *= -1 
		direction *= -1 
		
func receive_damage_state(delta):
	if not anima.is_playing():
		if health > 0:
			go_to_walk_state()
		else:
			go_to_dead_state()

func dead_state(_delta): 
	pass 
	
func take_damage(damage = 1): 
	if status == BigRedState.dead:
		return
	health -= damage
	if health > 0:
		go_to_receive_damage_state()
	else:
		go_to_dead_state()