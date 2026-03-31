class_name FlyingEnemy
extends enemy             #Herança da Classe Inimigo 

@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector

var altitude: float = 50.0
var speed: float = 80.0
var direction: int = 1

func move():
	velocity.x = speed * direction
	
	velocity.y = -altitude            #voo em altura constante

	if wall_detector.is_colliding() or not ground_detector.is_colliding():
		turn_around()

func turn_around():
	direction *= -1
	
	wall_detector.target_position.x *= -1.          #inverter os detectores 
	ground_detector.target_position.x *= -1         

func _physics_process(delta):
	move()
	move_and_slide()