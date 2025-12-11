extends CharacterBody2D

signal win_signal()
signal loose_signal()

const SPEED = 400.0
const SPRINT_SPEED = 550.0
const JUMP_VELOCITY = -700.0
const GRAVITY = 1000.0

var player_hp = 3

var is_stunned: bool = false
var stun_delay: float = 0.0
const STUN_TIME = 0.5

var damage_delay: float = 0.0

var max_cam_x_position = 0.0
const camera_offset = 50.0

@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("PlayerSprite")

var is_double_jump: bool = false

func handle_collisions(delta: float):
	var platform = null
	var collision_count = get_slide_collision_count()
	for c in collision_count:
		var collision = get_slide_collision(c)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if "barnacle" in collider.name:
			if abs(normal.x) > 0.8:
				horizontal_bounce(true)
			elif abs(normal.y) > 0.8:
				vertical_bounce()

			player_hp -= 1
			print("Мы получили дамагу")
		
		if "Yellow" in collider.name:
			print("УНИЧТОЖИТЬ ЖЕЛТОГО!!!")
		

func _physics_process(delta: float) -> void:
	
	if player_hp <= 0:
		loose_signal.emit()
	
	clamp_to_camera(delta)
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if !is_stunned:
		if Input.is_action_pressed("sprint"):
			velocity.x = direction * SPRINT_SPEED
		else:
			velocity.x = direction * SPEED
			
		if direction != 0:
			sprite.flip_h = direction < 0
		
	else:
		handle_stun(delta)
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("ui_up") and not is_on_floor() and not is_double_jump:
		velocity.y = JUMP_VELOCITY / 1.3
		is_double_jump = true
	
	if not is_on_floor():
		pass
		#animation.play("double_jump" if is_double_jump else "jump")
	elif direction != 0:
		#animation.play("run")
		is_double_jump = false
	else:
		#animation.play("idle")
		is_double_jump = false
	
	handle_collisions(delta)
	move_and_slide()
	
	
	
func clamp_to_camera(delta):
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return

	# Размер окна
	var viewport_size = get_viewport().get_visible_rect().size
	var cam_pos = camera.global_position
	
	var half_width = viewport_size.x / 2

	if cam_pos.x + half_width > max_cam_x_position:
		max_cam_x_position = cam_pos.x + half_width
		if max_cam_x_position > camera.limit_right:
			max_cam_x_position = camera.limit_right
	
	if max_cam_x_position - global_position.x >= viewport_size.x - camera_offset: 
		horizontal_bounce(false)

	elif max_cam_x_position - global_position.x <= 0 + camera_offset:
		horizontal_bounce(false)
		
	
	#print(max_cam_x_position, "   ", global_position.x)

func handle_stun(delta):
	if stun_delay <= 0:
		is_stunned = false
	stun_delay -= delta


func horizontal_bounce(short_bounce: bool):
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = -direction * SPEED
	sprite.flip_h = !sprite.flip_h
	if short_bounce:
		stun_delay = STUN_TIME / 2
	else:
		stun_delay = STUN_TIME
	is_stunned = true


func vertical_bounce():
	velocity.y = JUMP_VELOCITY
