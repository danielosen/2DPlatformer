extends Node2D
export var hp = 10
var timerDeath = 0.3
onready var sprite = get_node("Sprite")
func take_damage(damage):
	hp -= damage
	if hp <= 0:
		die()
		
func die():
	set_fixed_process(true)
	
func _ready():
	pass
	
func _fixed_process(dt):
	timerDeath -= dt
	if timerDeath > 0.2:
		sprite.set_region_rect(Rect2(16,0,16,16))
	elif timerDeath > 0.1:
		sprite.set_region_rect(Rect2(0,16,16,16))
	elif timerDeath <= 0:
		queue_free()