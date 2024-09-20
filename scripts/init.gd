extends Node2D

const CAMERA_ZOOM = 2
var dragging = false
var click_radius = 32 # Size of the sprite.

@onready var vache: AnimatedSprite2D = $Vache

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if (event.position - $Vache.position*CAMERA_ZOOM).length() < click_radius:

			# Start dragging if the click is on the sprite.
			if not dragging and event.pressed:
				dragging = true
		# Stop dragging if the button is released.
		if dragging and not event.pressed:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		# While dragging, move the sprite with the mouse.
		$Vache.position = event.position /CAMERA_ZOOM

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hello world !")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
