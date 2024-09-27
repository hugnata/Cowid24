extends Control

@onready var button: Button = $Button
@onready var label: Label = $Label
@onready var gamu: Node2D = $".."


func display_game_over():
	label.text = "Game Over"
	button.text = "Start again"
	button.pressed.connect(self.game_over)
	self.visible = true
	
func display_endless(score: int):
	label.text = "You got " + str(score) + " cows !"
	button.text = "Start again"
	button.pressed.connect(self.game_over)
	self.visible = true
	
func display_success():
	label.text = "Level completed !"
	button.text = "Next level"
	button.pressed.connect(self.next_level)
	self.visible = true
	
func next_level():
	self.visible = false
	button.pressed.disconnect(self.next_level)
	gamu.next_level()

func game_over():
	self.visible = false
	button.pressed.disconnect(self.game_over)
	gamu.reset_level()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(gamu)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
