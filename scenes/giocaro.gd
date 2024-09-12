extends Sprite2D


enum direction {UP,DOWN,RIGHT,LEFT}
var facing=direction.UP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var moving=false
	
	if Input.is_action_pressed("move_down"):
		facing=direction.DOWN
		$GiocaroAnimation.animation = 1
	elif Input.is_action_pressed("move_left"):
		facing=direction.LEFT
		moving=true
	elif Input.is_action_pressed("move_right"):
		facing=direction.RIGHT
		moving=true
	elif Input.is_action_pressed("move_up"):
		facing=direction.UP
		moving=true
		
	if velocity.length()>0:
		velocity= velocity.normalized()*speed
		$AnimatedSprite2D.play()
	else :
		$AnimatedSprite2D.stop()
		
	if velocity.x!=0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h =velocity.x<0
	elif velocity.y!=0:
		$AnimatedSprite2D.animation ="up"
		$AnimatedSprite2D.flip_v = velocity.y>0
	
	pass
