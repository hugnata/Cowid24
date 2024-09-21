extends Node

const Cow = preload("res://scenes/vache.gd")

# The approximated cow size, in pixels (to ensure that cow do no spawn on fences)
@export var COW_SIZE = 20
# The area the cow will spawn in. The shape of the CollisionShape2D must be a rectangle
@export var spawning_area : CollisionShape2D 
# The node that will contain all the cow as childrens
@export var cows_node : Node

@onready var rng = RandomNumberGenerator.new()

var m_timer_check_sick_cows:Timer = Timer.new()

func _ready() -> void:
	assert(spawning_area.shape.get_class()=="RectangleShape2D" && 
	"The cow manager script only handles Rectangle Spawning Area for now")
	assert(cows_node != null && "You must provide a node to contains the cows !")
	
func start_infection() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 5 # Wait for 5 seconds before the first infection
	timer.one_shot = false
	timer.start()
	timer.connect("timeout", infect_patient_zero)
	
func spawn_cows(number: int):
	for i in range(number):
		spawn_cow()

func spawn_cow():
	print("Hello, I'm a cow ")
	var cow_scene = preload("res://scenes/vache.tscn")
	var spawning_rectangle : Rect2 = spawning_area.shape.get_rect()
	var position = spawning_area.get_global_transform().get_origin() + spawning_rectangle.position
	var size = spawning_rectangle.size
	var x = randi_range(position.x+COW_SIZE,position.x + size.x  - COW_SIZE)
	var y = randi_range(position.y+COW_SIZE,position.y + size.y  - COW_SIZE)
	var cow: Node2D = cow_scene.instantiate()
	cow.set_global_position(Vector2(x,y))
	cows_node.add_child(cow)
	
func infect_patient_zero():
	# Only infect a patient Zero if no one is infected
	if get_number_infected() > 0:
		return
	var healthy_cows : Array = cows_node.get_children().filter(
		 func(cow) : return cow.get_state() == Cow.HealthState.HEALTHY
	)
	if healthy_cows.size() == 0:
		return
	var the_chosen_one = healthy_cows.pick_random()
	the_chosen_one.set_health_state(Cow.HealthState.CONTAMINATED)
	
func get_number_infected() -> int:
	return cows_node.get_children().filter(
		func(cow) : return cow.get_state() != Cow.HealthState.HEALTHY
	).size()
