extends Label

@onready var cow_manager: Node = get_node("/root/gamu/Cow Manager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var nb_infected = cow_manager.get_number_infected()
	var nb_sick = cow_manager.get_number_sick()
	if nb_sick == 1:
		self.text = "The infected cow turned into a zombie oO Fortunately it will \
		heal itself soon"
		return 
	if nb_infected == 1:
		self.text = "A cow has been infected! \
					Try to find it, and isolate it. \
					A small hint: it farts more often than other cows"
	if nb_infected == 2:
		self.text = "Two cows infected! It is starting to be dangerous"
