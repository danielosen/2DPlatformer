extends KinematicBody2D
onready var sprite = get_node("Sprite")
onready var animPlayer = get_node("AnimationPlayer")
var playerBody = null
var hp = 20
var speed = 0.75
var timerUpdateAI = 0.5
var targetPos = Vector2()
var dying = false
var experience = 10
var damage = 5
func _ready():
	get_node("AnimationPlayer").play("idle")
	pass

func take_damage(damage):
	hp -= damage
	if hp <= 0:
		die()
		return true
	return false

func die():
	animPlayer.play("die")
	dying = true
	#queue_free()
	
func activate_bat( body ):
	playerBody = body
	set_fixed_process(true)
	animPlayer.play("fly")
	
func _fixed_process(dt):
	if not dying:
		if timerUpdateAI >= 0.5:
			targetPos = playerBody.get_pos()
			timerUpdateAI = 0
		var moveVec = (targetPos-get_pos()).normalized()
		if moveVec.x > 0:
			sprite.set_flip_h(true)
		elif moveVec.x < 0:
			sprite.set_flip_h(false)
		move(moveVec*speed)
		timerUpdateAI += dt
		if is_colliding():
			var collider = get_collider()
			if collider.is_in_group("Player"):
				var n = get_collision_normal()
				collider.take_damage(damage,n)
	else:
		if animPlayer.get_pos() >= animPlayer.get_current_animation_length():
			queue_free()
