extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var nb_cows_label: Label = $"Contamination data/nb cows"
@onready var nb_contaminated_label: Label = $"Contamination data/nb contaminated"

var nb_cows = 0
func update_vaccine_progression(progression: int) -> void:
	progress_bar.set_value(progression)
	
func update_number_of_cows(nb: int) -> void:
	nb_cows = nb
	nb_cows_label.text = str(nb)
	
func update_number_contaminated(nb: int) -> void:
	nb_contaminated_label.text = str(nb)
	if nb_cows == 0:
		return
	var contamination_ratio = nb as float/nb_cows
	
	nb_contaminated_label.remove_theme_color_override("font_color")
	if contamination_ratio > 0.6:
		nb_contaminated_label.add_theme_color_override("font_color", Color.DARK_RED)
		return
	if contamination_ratio > 0.4:
		nb_contaminated_label.add_theme_color_override("font_color", Color.ORANGE_RED)
		return
	if contamination_ratio > 0.2:
		nb_contaminated_label.add_theme_color_override("font_color", Color.ORANGE)
		return
	if contamination_ratio > 0:
		nb_contaminated_label.add_theme_color_override("font_color", Color.LIGHT_GOLDENROD)
		return
	nb_contaminated_label.add_theme_color_override("font_color", Color.WHITE)



	
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
