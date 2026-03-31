class_name FlyingEnemy
extends enemy             #Herança da Classe Inimigo 

enum State {
	fly
}

@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector

var state = Big_BossState

var altitude: float = 50.0
var speed: float = 80.0
var direction: int = 1

func go_to_fly_state():                            #estado de transição para o inimigo patrulhar
	status = Big_BossState.fly
	anima.play("fly")     

func _physics_process(delta):
	move(delta)
    	match state:
			Big_BossState.fly:                 #O status do Big boss que al[em das funções do enemy, voa]
				fly_state(delta)
	move_and_slide()

func fly_state(delta):                     #função de voar
	move(delta)

    func move(delta):
	velocity.x = speed * direction
	
	velocity.y = -altitude            #voo em altura constante

	if wall_detector.is_colliding() or not ground_detector.is_colliding():
		turn_around(delta)

func turn_around(delta):
	direction *= -1
	
	wall_detector.target_position.x *= -1         #inverter os detectores 
	ground_detector.target_position.x *= -1    