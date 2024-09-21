extends CharacterBody2D

@onready var rng = RandomNumberGenerator.new()


enum MovingState{STATIC,MOVING}

#Constants
const SPEED =20.0

#Member variables
var m_time_until_next_move: float = 0 
var m_moving_state:MovingState=MovingState.MOVING
@export var enclos: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VacheSprite/VachAnimation.play("moving")
	velocity = Vector2.ZERO
	
	
func _physics_process(delta: float) -> void:
	m_time_until_next_move-=delta
	if m_time_until_next_move<=0:
		change_moving_state()
	
	
	if move_and_slide():
		change_moving_state()
	
func change_moving_state():
	match m_moving_state:
		MovingState.STATIC:
			m_moving_state=MovingState.MOVING
			m_time_until_next_move=rng.randf_range(1,3)
			$VacheSprite/VachAnimation.play("moving")
			velocity=Vector2(rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()*SPEED
			$VacheSprite.flip_h=velocity.x<=0
		MovingState.MOVING:
			m_moving_state=MovingState.STATIC
			m_time_until_next_move=rng.randf_range(1,11)
			velocity=Vector2.ZERO
			$VacheSprite/VachAnimation.play("idle")
	
	 
	
		
	
		
	
