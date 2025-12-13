extends CharacterBody2D

signal win_signal()
signal loose_signal()

signal static_collision(collider)

const SPEED = 400.0
const SPRINT_SPEED = 550.0
const JUMP_VELOCITY = -700.0
const GRAVITY = 1000.0

const MAX_PLAYER_HP = 5
var player_hp = 5

var is_damaged: bool = false
var damage_delay: float = 0.0
const DAMAGE_STUN: float = 0.5

var is_stunned: bool = false
var stun_delay: float = 0.0
const STUN_TIME = 0.5

var max_cam_x_position = 0.0
const camera_offset = 50.0

@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("PlayerSprite")
@onready var canvas = get_node("Camera2D/CanvasLayer")

var is_double_jump: bool = false

func _ready() -> void:
	get_parent().connect("change_player_hp", _on_hp_change)
	
func handle_collisions(delta: float):
	var platform = null
	var collision_count = get_slide_collision_count()
	for c in collision_count:
		var collision = get_slide_collision(c)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if collider == null:
			return
		if "barnacle" in collider.name:
			if abs(normal.x) > 0.8:
				horizontal_bounce(true)
			elif abs(normal.y) > 0.8:
				vertical_bounce()
			
			take_damage(1)
			print("Мы получили дамагу")
		
		if "slime" in collider.name:
			if abs(normal.x) > 0.8:
				horizontal_bounce(true)
				take_damage(1)
				print("Мы получили дамагу")
			if abs(normal.y) > 0.8:
				vertical_bounce()
				animate_block(collider, true)
		if "cube_enemy" in collider.name:
			if abs(normal.x) > 0.8:
				horizontal_bounce(true)
				take_damage(1)
				print("Мы получили дамагу")
			if abs(normal.y) > 0.8:
				vertical_bounce()
				animate_block(collider, true)
				
		if "Yellow" in collider.name:
			if normal.y > 0.8:
				static_collision.emit(collider)
		if "Grass" in collider.name:
			if normal.y > 0.8:
				static_collision.emit(collider)
		if "Lever" in collider.name:
			if normal.x > 0.8:
				collider.name = "Lever_to_left"
			elif normal.x < -0.8:
				collider.name = "Lever_to_right"
			static_collision.emit(collider)
		
			

func _physics_process(delta: float) -> void:
	
	handle_hp()
	
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
	
	if is_damaged:
		handle_damage(delta)
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("ui_up") and not is_on_floor() and not is_double_jump:
		velocity.y = JUMP_VELOCITY / 1.3
		is_double_jump = true
	
	if not is_on_floor():
		#pass
		#animation.play("double_jump" if is_double_jump else "jump")
		animation.play("jump")
	elif direction != 0:
		animation.play("walk")
		is_double_jump = false
	else:
		animation.play("idle")
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
	
	
func handle_damage(delta):
	if damage_delay <= 0:
		is_damaged = false
	damage_delay -= delta


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


func animate_block(collider, to_destroy: bool):
	collider.get_child(1).play("break")  # Обращаемся к анимейшн плееру
	if to_destroy:
		collider.get_child(2).disabled = true  # Обращаемся к колижен шейп
		await collider.get_child(1).animation_finished
		collider.queue_free()
		

func handle_hp():
	if player_hp <= 0:
		loose_signal.emit()
	
	if player_hp == 1:
		canvas.get_child(0).get_child(0).visible = false ## Меняем вид сердечка
		canvas.get_child(0).get_child(1).visible = true ## Меняем вид сердечка
		animation.play("low_hp")
	elif player_hp > 1:
		canvas.get_child(0).get_child(0).visible = true
		canvas.get_child(0).get_child(1).visible = false
	
	for i in range(1, MAX_PLAYER_HP + 1):
		if i == player_hp:
			canvas.get_child(i).visible = true
		else:
			canvas.get_child(i).visible = false
	
func _on_hp_change(diff: int):
	player_hp = min(player_hp + diff, MAX_PLAYER_HP)

func take_damage(damage: int):
	if !is_damaged:
		player_hp -= damage
		is_damaged = true
		damage_delay = DAMAGE_STUN
