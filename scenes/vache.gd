extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$VachAnimation.animation = "idle"
	$VacheSprite/VachAnimation.play("idle")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
