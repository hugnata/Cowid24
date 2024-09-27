extends Node2D

@onready var start_button: Button = $StartButton
@onready var endless_button: Button = $EndlessButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(self.start_game)
	endless_button.pressed.connect(self.endless_mode)

func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/gamu.tscn")

func endless_mode() -> void:
	get_tree().change_scene_to_file("res://scenes/endless.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
