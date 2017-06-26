extends KinematicBody2D

#member vars

var timerGravity = 0
var timerWalking = 0
var timerJumping = 0
var timerAttacking = 0
var timerInvulnerability = 2
var futureDeltaY = 0
var experience = 0
var agility = 2
var strength = 2
var intelligence = 2
var maxJumpTime = 1.6*(1+agility/100)
var maxSpeed = 2*(1+agility/100)
var meleeDamage = 10 + strength
var hp = 60 + 2*strength
#nodes
onready var camera = get_node("Camera2D")
onready var sprite = get_node("Sprite")
onready var animPlayer = get_node("AnimationPlayer")
onready var forwardAttackHitBox = get_node("Melee HitBox/Forward Attack")
onready var meleeHitBox = get_node("Melee HitBox")

#finite state machine
var stateIdle = false
var stateWalking = false
var stateJumping = false
var stateGrounded = false
var stateFalling = false
var stateAttacking = false
var currentState
var currentAnim


func updateState(inputVec,colResult):
	
	stateGrounded = not colResult["down"].empty()
	
	if inputVec.x != 0 and stateGrounded:
		
		stateWalking = true
		
	elif inputVec.x == 0 and stateGrounded:
		
		stateWalking = false
		stateIdle = true
		
	if inputVec.y > 0 and stateGrounded:
		stateGrounded = false
		stateJumping = true
	
	if timerJumping >= maxJumpTime and stateJumping:
		stateJumping = false
	elif timerJumping < maxJumpTime and stateGrounded:
		stateJumping = false
	
	stateFalling = not stateJumping and not stateGrounded
	
	stateIdle = not stateJumping and not stateWalking and stateGrounded
	
	stateAttacking = inputVec.z > 0 and stateGrounded and not stateWalking


func getInput():
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	var jump = Input.is_action_pressed("jump")
	var attack = Input.is_action_pressed("attack")
	var inputVec = Vector3(right-left,jump,attack)
	return inputVec

func getCollision():
	var space = get_world_2d().get_direct_space_state()
	var ray_down_center = space.intersect_ray(get_pos()+Vector2(0,0),get_pos()+Vector2(0,22),[self])
	var colResult = {"down" : ray_down_center}
	return colResult
	
func updateTimers(dt):
	
	var fallVec = Vector2(0,0)
	
	if not stateGrounded and not stateJumping:
		fallVec.y = timerGravity*timerGravity
		timerGravity += 3*dt
	else:
		timerGravity = 0
	
	if stateJumping:
		timerJumping += 3*dt
		fallVec.y = -maxJumpTime+timerJumping
	else:
		timerJumping = 0
	
	if stateAttacking:
		timerAttacking += dt
	else:
		timerAttacking = 0
		meleeHitBox.set_enable_monitoring(false)
		
	timerInvulnerability = min(timerInvulnerability+dt,2.0)
	
	return fallVec
	
func updateAnimation(moveVec,dt):
	var anim = ""

	if moveVec.x < 0:
		sprite.set_scale(Vector2(-1,1))
		forwardAttackHitBox.set_scale(Vector2(-1,1))
	elif moveVec.x > 0:
		sprite.set_scale(Vector2(1,1))
		forwardAttackHitBox.set_scale(Vector2(1,1))
		
		
	if stateWalking and stateGrounded:
		anim = "walk"
	elif stateIdle:
		anim = "idle"
		
	elif stateFalling:
		anim = "fall"
	
	elif stateJumping:
		anim = "jump"
	
	if stateAttacking:
		anim = "attack"
	
	if animPlayer.get_current_animation() != anim:
		
		animPlayer.set_current_animation(anim)
	
	elif animPlayer.get_pos() == animPlayer.get_current_animation_length():
		
		animPlayer.set_current_animation(anim)
	
	animPlayer.advance(dt)
	
func alignMovement(inputVec,colResult):
	var moveVec = Vector2(inputVec.x,0)
	if stateGrounded:
		var collider = colResult["down"].collider
		var position = colResult["down"].position
		move_to(position-Vector2(0,21)) #puts our feet just 1 pixel inside the collision shape
		if collider.is_in_group("map") and moveVec.x != 0:
			var tileIndex = collider.get_cellv(collider.world_to_map(position))
			var deltaX = 1
			var deltaY = 0
			if tileIndex == collider.SLOPE45DOWN:
				deltaY = 1
			elif tileIndex == collider.SLOPE45UP:
				deltaY = -1
			else: #we are not standing on a slope, but we are standing on ground
				var futurePos = Vector2(position.x+moveVec.x*maxSpeed,position.y)
				var tileIndexRight = collider.get_cellv(collider.world_to_map(futurePos))
				if tileIndexRight == collider.SLOPE45DOWN:
					print("slope going down from left to right")
					futureDeltaY = futurePos.x-16*floor(futurePos.x/16)
					print(futureDeltaY)
				elif tileIndexRight == collider.SLOPE45UP:
					print("slope going up from left to right")
					futureDeltaY = -futurePos.x+16*ceil(futurePos.x/16)
					print(futureDeltaY)
			moveVec = Vector2(deltaX,deltaY).normalized()*sign(moveVec.x)
	return moveVec

func _fixed_process(dt):
	
	var inputVec = getInput()
	
	var colResult = getCollision()
	
	updateState(inputVec,colResult)
	
	var fallVec = updateTimers(dt)
	
	var moveVec = alignMovement(inputVec,colResult)
	
	updateAnimation(inputVec,dt)
	
	#ACTUAL COLLISIONS WITH KINEMATICBODY (not ground!)
	if test_move(Vector2(moveVec.x,0)): #slide off walls
		moveVec.x = 0
	if is_colliding(): #small body colliding (walls etc)
		var n = get_collision_normal()
		var angle = rad2deg(acos(n.dot(Vector2(0,-1))))
		if angle < 90:
			timerGravity = 0
			moveVec += n
			move(n.slide(moveVec+fallVec))
		else:
			move(moveVec+fallVec)
	else:
		
		move(moveVec*maxSpeed+fallVec)
		if futureDeltaY != 0:
			move(Vector2(0,futureDeltaY))
			futureDeltaY = 0
	debug()

func take_damage(damage,normal):
	if timerInvulnerability >= 2:
		hp -= damage
		move(-normal*40)
		timerInvulnerability = 0

func debug():
	#var string = ( "idle" + str(stateIdle) +"walking" + str(stateWalking)
	#+ "\n" + "jumping" + str(stateJumping) + "falling" + str(stateFalling)
	#+ "\n" +"grounded" +str(stateGrounded) + "\n" + "attck" + str(stateAttacking))
	#get_parent().get_node("Canvas Layer 2D/Label").set_text(string)
	#get_parent().get_node("Canvas Layer 2D/Panel/Label").set_text("HP: "+str(hp))
	#get_parent().get_node("Canvas Layer 2D/Panel/Label").set_text("Current FPS: " + str(OS.get_frames_per_second()))
	#get_parent().get_node("Canvas Layer 2D/Panel/Label").set_text("EXP: " + str(experience))
	#get_parent().get_node("Canvas Layer 2D/Panel/Label").set_text("hp: " + str(hp) + (
	# " str:" + str(strength) + " agi:" + str(agility) + " int:" + str(intelligence)))
	#get_parent().get_node("Canvas Layer 2D/Panel/Label").set_text(str(stateGrounded))
	pass
	
func _on_Melee_HitBox_body_enter( body ):
	if body.get_parent().is_in_group("Destructible"):
		body.get_parent().take_damage(meleeDamage)
	elif body.is_in_group("Enemy"):
		var died = body.take_damage(meleeDamage)
		if died:
			experience += body.experience
		
	pass # replace with function body

func _ready():
	OS.set_target_fps(60)
	set_fixed_process(true)
	
	pass