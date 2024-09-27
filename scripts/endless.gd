extends Node2D

@onready var cow_manager: Node = $"Cow Manager"
@onready var cows: Node = $Cows
@onready var ui: Control = $StatUI
@onready var main_ui: Control = $MainUi

@export var spawned_cow=20
@export var levels : Array[Resource] 

const Cow = preload("res://scenes/vache.gd")

const CAMERA_ZOOM = 2
const TIME_BETWEEN_COW_SPAWN = 5
const TIME_BETWEEN_COW_INFECTED = 30

var map: Node2D # The current level
var CLICK_RADIUS = 32 # Size of the sprite.
var cow_dragged = null
var last_valid_position = null
var time_since_last_spawn = 5
var time_since_last_disease_spread = 5
var vaccine_dev_time = INF
var current_level = 0
var paused = false
var max_cow_simultaneous = 0

func next_level():
	current_level += 1
	print(levels[current_level].resource_path)
	switch_to_level(levels[current_level].resource_path)
	paused = false

func reset_level():
	switch_to_level(levels[current_level].resource_path)
	paused = false

func load_level(level_path: String):
	# Reset all level variables
	cow_dragged = null
	last_valid_position = null
	time_since_last_spawn = 0
	# Load the new scene
	var level_scene = load(level_path)
	var level = level_scene.instantiate()
	self.add_child(level)
	map = level
	var nb_cows = 10
	cow_manager.spawn_cows(map, nb_cows)
	ui.update_number_of_cows(nb_cows)
	cow_manager.start_infection()
	
func clean_level():
	# Todo create a small transition to hide the depop
	# Remove all cows
	for cow in cows.get_children():
		cow.queue_free()
	self.remove_child(map)
	map = null
	
func switch_to_level(level_path: String):
	clean_level()
	load_level(level_path)

func screen_to_world_pos(pos: Vector2) -> Vector2:
	return pos/2 

## Drag'n'drop logic
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Start dragging if the click is on the sprite.
		if cow_dragged == null and event.pressed:
			var mouse_world_pos = screen_to_world_pos(event.position)
			# Best candidate so far to drag & drop
			var closest_cow = null
			var min_distance = INF
			# Find the closest cow to the cursor (must be closer than CLICK_RADIUS)
			for cow in cows.get_children():
				var distance = (mouse_world_pos - cow.position).length()
				if distance < CLICK_RADIUS:
					if distance < min_distance:
						closest_cow = cow
						min_distance = distance
#			
			cow_dragged = closest_cow
			if cow_dragged!=null:
				last_valid_position = cow_dragged.position
				cow_dragged.stop_moving_madafaka()
				cow_dragged.disable_collisions()
				
				
		# Stop dragging if the button is released.
		if cow_dragged and not event.pressed:
			cow_dragged.position = last_valid_position
			cow_dragged.enable_collisions()
			cow_dragged.move_ya_ass()
			cow_dragged = null
			last_valid_position = null
			
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_world_pos = screen_to_world_pos(event.position)
		# Best candidate so far to drag & drop
		var min_distance = INF
		var closest_cow = null
		# Find the closest cow to the cursor (must be closer than CLICK_RADIUS)
		for cow in cows.get_children():
			var distance = (mouse_world_pos - cow.position).length()
			if distance < CLICK_RADIUS:
				if distance < min_distance:
					closest_cow = cow
					min_distance = distance
		
		if closest_cow:
			closest_cow.set_health_state(1)
#
	if event is InputEventMouseMotion and cow_dragged != null:
		# While dragging, move the sprite with the mouse.
		cow_dragged.position =  screen_to_world_pos(event.position)
		if map.is_viable_drop_location(cow_dragged.position):
			last_valid_position = cow_dragged.position

# Called when game is over, after 2 second of delay
func game_over(timer: Timer):
	self.main_ui.display_endless(max_cow_simultaneous)
	timer.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level("res://scenes/endless_level.tscn")
	
func stop_all_cows():
	for cow in cows.get_children():
		cow.stop_moving_madafaka()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if paused:
		return
	time_since_last_spawn += delta
	time_since_last_disease_spread += delta
	
	if time_since_last_spawn >= TIME_BETWEEN_COW_SPAWN:
		time_since_last_spawn = 0
		cow_manager.spawn_cow(map)
		ui.update_number_of_cows(cow_manager.get_number_cows())
	
	if time_since_last_disease_spread >= TIME_BETWEEN_COW_INFECTED:
		time_since_last_disease_spread = 0
		
		# Find a healthy cow to contaminate
		var selected_cow = cows.get_children().filter(func(cow) : 
				return (cow.get_state() == Cow.HealthState.HEALTHY)
				).pick_random()
		
		selected_cow.set_health_state(Cow.HealthState.CONTAMINATED)
		
	# Remove all cow "Immunized", aka dead in this game mode
	for cow: Node2D in cows.get_children():
		if cow.get_state() == Cow.HealthState.IMMUNIZED:
			if cow == cow_dragged:
				cow_dragged = null
				last_valid_position = null
			cow.queue_free()
			ui.update_number_of_cows(cow_manager.get_number_cows())
	
		
	
	var number_infected = cow_manager.get_number_infected()
	var nb_cows = cow_manager.get_number_cows()
	if nb_cows > max_cow_simultaneous:
		max_cow_simultaneous = nb_cows
	update_ui()
	if (number_infected as float / nb_cows) >= 0.5:
		paused = true
		var timer = Timer.new()
		self.add_child(timer)
		timer.wait_time = 2
		timer.one_shot = true
		timer.start()
		timer.connect("timeout", game_over.bind(timer))
		stop_all_cows()
		
func update_ui():
	ui.update_number_contaminated(cow_manager.get_number_infected())
	
