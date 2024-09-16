extends Node2D

@onready var dialog: Node2D = $Dialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog.start_dialog("res://assets/Dialogs/first_dialog.txt")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		print("Going up !")
		dialog.start_dialog("res://assets/Dialogs/first_dialog.txt")
