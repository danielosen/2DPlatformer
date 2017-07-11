extends KinematicBody2D 

onready var animPlayer = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
var hp = 30
var experience = 25
var timer = 0
var damage = 10
func _ready():
	set_fixed_process(true)
	animPlayer.play("walk")
	pass
	
func _fixed_process(dt):
	timer += dt
	if sin(timer) > 0:
		sprite.set_flip_h(true)
		move(Vector2(0.2,0))
	else:
		sprite.set_flip_h(false)
		move(Vector2(-0.2,0))
	
	if timer >= 2*PI:
		timer = 0

func die():
	queue_free()
func take_damage(damage):
	hp -= damage 
	if hp <= 0:
		die()
		return true
	else:
		return false
	

