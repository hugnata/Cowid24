extends Node2D

@onready var cow_manager: Node = $"Cow Manager"
@onready var cows: Node = $Cows
@onready var ui: Control = $StatUI
@onready var main_ui: Control = $MainUi

@export var spawned_cow=20
@export var levels : Array[Resource] 

const CAMERA_ZOOM = 2

var map: Node2D # The current level
var CLICK_RADIUS = 32 # Size of the sprite.
var cow_dragged = null
var last_valid_position = null
var time_elapsed = 0
var vaccine_dev_time = INF
var max_infected_cows
var current_level = 0
var paused = false

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
	time_elapsed = 0
	# Load the new scene
	var level_scene = load(level_path)
	var level = level_scene.instantiate()
	self.add_child(level)
	map = level
	var nb_cows = map.nb_spawned_cows 
	vaccine_dev_time = map.vaccine_dev_time
	cow_manager.spawn_cows(map, nb_cows)
	ui.update_number_of_cows(nb_cows)
	max_infected_cows = map.max_infected_cows
	ui.update_goal(max_infected_cows)
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level("res://scenes/level_1.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	var number_infected = cow_manager.get_number_infected()
	update_ui()
	if number_infected >= max_infected_cows:
		paused = true
		main_ui.display_game_over()
	if time_elapsed > vaccine_dev_time:
		paused = true
		main_ui.display_success()

func update_ui():
	var progression = 100*time_elapsed/ vaccine_dev_time
	progression = min(progression, 100)
	ui.update_vaccine_progression(progression)
	ui.update_number_contaminated(cow_manager.get_number_infected())
	
