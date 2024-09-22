extends Label

@onready var stat_ui: Control = $StatUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stat_ui.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
