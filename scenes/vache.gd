extends CharacterBody2D

@onready var rng = RandomNumberGenerator.new()

enum MovingState{STATIC,MOVING}
enum HealthState{HEALTHY=0,CONTAMINATED=1,SICK=2,IMMUNIZED=3}

#Constants
const SPEED =20.0

#Member variables
var m_move_timer: float = 0.0 
var m_sickness_timer:float=0.0
var m_infection_timer:float=0.0
var m_moving_state:MovingState=MovingState.MOVING
var m_health_state:HealthState=HealthState.HEALTHY
var m_animation_cycle:AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_animation_cycle=$VacheSprite/VachAnimation
	m_animation_cycle.play("moving")
	velocity = Vector2.ZERO
	
func _process(delta: float) -> void:
	infects_other(delta)
	progress_desease(delta)

func _physics_process(delta: float) -> void:
	m_move_timer-=delta
	if m_move_timer<=0:
		change_moving_state()
	
	if move_and_slide():
		change_moving_state()
		
func progress_desease(delta: float):
	m_sickness_timer-=delta
	if(m_health_state==HealthState.HEALTHY):
		return
	if m_sickness_timer>0:
		return
	
	match m_health_state:
		HealthState.CONTAMINATED:
			m_sickness_timer=rng.randf_range(15,30)
			m_health_state=HealthState.CONTAMINATED
			
		HealthState.SICK:
			m_sickness_timer=rng.randf_range(20,30)
			m_health_state=HealthState.IMMUNIZED
		HealthState.IMMUNIZED:
			m_sickness_timer=rng.randf_range(10,15)
			m_health_state=HealthState.HEALTHY
			
func infects_other(delta: float): 
	m_infection_timer-=delta
	if m_infection_timer>0:
		return
	if m_health_state==HealthState.HEALTHY:
		return
	
	match m_health_state:
		HealthState.CONTAMINATED:
			m_sickness_timer=0.5
		HealthState.SICK:
			m_sickness_timer=0.5
			
	#Infection
	var infections_areas: Array[Area2D]=$InfectionZone.get_overlapping_areas()
	if infections_areas.is_empty():
		return
	

func change_moving_state():
	match m_moving_state:
		MovingState.STATIC:
			m_moving_state=MovingState.MOVING
			m_move_timer=rng.randf_range(1,3)
			m_animation_cycle.play("moving")
			m_animation_cycle
			velocity=Vector2(rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()*SPEED
			$VacheSprite.flip_h=velocity.x<=0
		MovingState.MOVING:
			m_moving_state=MovingState.STATIC
			m_move_timer=rng.randf_range(1,11)
			velocity=Vector2.ZERO
			m_animation_cycle.play("idle")

func get_state():
	return m_health_state

func set_health_state(new_health_state: HealthState):
	m_health_state=new_health_state
	if m_health_state==HealthState.HEALTHY:
		return
		
	m_infection_timer=10.0
	m_sickness_timer=10.0
	
func stop_moving_madafaka():
	m_move_timer=INF
	velocity=Vector2.ZERO
	m_animation_cycle.pause()
	
func move_ya_ass():
	m_move_timer=0


		
	
		
	
