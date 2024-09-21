extends Node2D

@onready var cow_manager: Node = $"Cow Manager"
@onready var cows: Node = $Cows
@onready var map: Node2D = $Map
@onready var ui: Control = $UI

const VACCINE_DEVELOPMENT_TIME = 1 * 60 # Set to 3 minutes by default

const CAMERA_ZOOM = 2
var CLICK_RADIUS = 32 # Size of the sprite.
var cow_dragged = null
var last_valid_position = null
var time_elapsed = 0

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
				
		# Stop dragging if the button is released.
		if cow_dragged and not event.pressed:
			cow_dragged.position = last_valid_position
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
	print("Hello world !")
	cow_manager.spawn_cows(20)
	ui.update_number_of_cows(20)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	var progression = 100*time_elapsed/ VACCINE_DEVELOPMENT_TIME
	progression = min(progression, 100)
	ui.update_vaccine_progression(progression)
	ui.update_number_contaminated(int(progression*5/100))
