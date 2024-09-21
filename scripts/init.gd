extends Node2D

const CAMERA_ZOOM = 2
var CLICK_RADIUS = 32 # Size of the sprite.
var cow_dragged = null
var last_valid_position = null

@onready var cow_manager: Node = $"Cow Manager"
@onready var cows: Node = $Cows
@onready var map: Node2D = $Map

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
#
	if event is InputEventMouseMotion and cow_dragged != null:
		# While dragging, move the sprite with the mouse.
		cow_dragged.position =  screen_to_world_pos(event.position)
		if map.is_viable_drop_location(cow_dragged.position):
			last_valid_position = cow_dragged.position
			
		


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hello world !")
	cow_manager.spawn_cows(5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
