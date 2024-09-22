extends CharacterBody2D

@onready var rng = RandomNumberGenerator.new()
@onready var hit_box: CollisionShape2D = $HitBox

@export var avg_time_sec_between_farts_when_healthy_sec=20
@export_category("Infection factors")
@export_range(0.0,1.0) var infection_chance: float 
@export_range(1,999999) var max_nb_infectef_cows_once : int

enum MovingState{STATIC,MOVING}
enum HealthState{HEALTHY=0,CONTAMINATED=1,SICK=2,IMMUNIZED=3}

#Constants
const SPEED =20.0

#Member variables
var m_move_timer: float = 0.0 
var m_sickness_timer:float=INF
var m_infection_timer:float=INF
var m_moving_state:MovingState=MovingState.MOVING
var m_health_state:HealthState=HealthState.HEALTHY
var m_animation_cycle:AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_animation_cycle=$VacheSprite/VachAnimation
	$Fart.connect("animation_finished",func (): $Fart.visible=false)
	$Fart.visible=false
	m_animation_cycle.play("moving")
	velocity = Vector2.ZERO
	
func _process(delta: float) -> void:
	
	var chance_2_fart=1.0/avg_time_sec_between_farts_when_healthy_sec*delta
	
	if rng.randf()<chance_2_fart:
		print("Healthy fart")
		fart()
	
	infects_other(delta)
	progress_desease(delta)
	update_animation()

func _physics_process(delta: float) -> void:
	m_move_timer-=delta
	if m_move_timer<=0:
		change_moving_state()
	
	if move_and_slide():
		change_moving_state()
		
func progress_desease(delta: float,force_new_health_state =-1):
	m_sickness_timer-=delta
	if(m_health_state==HealthState.HEALTHY and force_new_health_state==-1):
		return
	if m_sickness_timer>0 and force_new_health_state==-1:
		return
	
	match m_health_state:
		HealthState.HEALTHY:
			m_sickness_timer=rng.randf_range(10,30)
			m_infection_timer=rng.randf_range(5,10)
			m_health_state=HealthState.CONTAMINATED
			print("Now CONTAMINATED")
			
		HealthState.CONTAMINATED:
			m_sickness_timer=rng.randf_range(15,30)
			m_infection_timer=rng.randf_range(2,4)
			m_health_state=HealthState.SICK
			print("Now SICK")
			
		HealthState.SICK:
			m_sickness_timer=rng.randf_range(3,6)
			m_infection_timer=INF
			m_health_state=HealthState.IMMUNIZED
			print("Now IMMUNIZED")
			
		HealthState.IMMUNIZED:
			m_sickness_timer=INF
			m_health_state=HealthState.HEALTHY
			print("Now HEALTHY")
			
func infects_other(delta: float): 
	m_infection_timer-=delta
	if m_infection_timer>0:
		return
	if m_health_state==HealthState.HEALTHY:
		return
	
	fart()
	
	match m_health_state:
		HealthState.CONTAMINATED:
			m_infection_timer=rng.randf_range(5,10)
			print("Infecting")
		HealthState.SICK:
			m_infection_timer=rng.randf_range(2,4)
			print("Infecting")
			
	#Infection
	var infections_areas: Array[Area2D]=$InfectionZone.get_overlapping_areas()
	if infections_areas.is_empty():
		return
	infections_areas=infections_areas.slice(0,min(infections_areas.size(),max_nb_infectef_cows_once))
	
	for infections_area in infections_areas:
		if rng.randf_range(0,1.0)<infection_chance:
			infections_area.get_parent().set_health_state(HealthState.CONTAMINATED)
		

func fart():
	if $Fart.visible:
		return
	$Fart.visible=true
	$Fart.play("fart")

	
func update_animation():
	if m_health_state in [HealthState.HEALTHY,HealthState.CONTAMINATED,HealthState.IMMUNIZED]:
		match m_moving_state:
			MovingState.STATIC:
				m_animation_cycle.play("idle")
			MovingState.MOVING:
				m_animation_cycle.play("moving")
	elif m_health_state in [HealthState.SICK]:
		match m_moving_state:
			MovingState.STATIC:
				m_animation_cycle.play("idle_sick")
			MovingState.MOVING:
				m_animation_cycle.play("moving_sick")
	
func update_animation_debug():
	if m_health_state==HealthState.HEALTHY or m_health_state==HealthState.IMMUNIZED:
		match m_moving_state:
			MovingState.STATIC:
				m_animation_cycle.play("idle")
			MovingState.MOVING:
				m_animation_cycle.play("moving")
	else:
		m_animation_cycle.play("sick")

func change_moving_state():
	match m_moving_state:
		MovingState.STATIC:
			m_moving_state=MovingState.MOVING
			m_move_timer=rng.randf_range(1,3)
			m_animation_cycle.play("moving")
			velocity=Vector2(rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()*SPEED
			$VacheSprite.flip_h=velocity.x<=0
			$Fart.flip_h=velocity.x<=0
			$Fart.position.x= abs($Fart.position.x)* (1 if velocity.x<=0 else -1)
			#print($Fart.position.x)
		MovingState.MOVING:
			m_moving_state=MovingState.STATIC
			m_move_timer=rng.randf_range(1,11)
			velocity=Vector2.ZERO
			m_animation_cycle.play("idle")

func get_state():
	return m_health_state

func set_health_state(new_health_state: HealthState):
	if m_health_state==HealthState.IMMUNIZED:
		print("Nope,immunized")
		return
	progress_desease(0.0,new_health_state)
	
func stop_moving_madafaka():
	m_move_timer=INF
	velocity=Vector2.ZERO
	m_animation_cycle.pause()
	
func move_ya_ass():
	m_move_timer=0

func disable_collisions():
	hit_box.disabled = true
	
func enable_collisions():
	hit_box.disabled = false

		
	
		
	
