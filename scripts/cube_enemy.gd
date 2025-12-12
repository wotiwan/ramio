extends CharacterBody2D

const SPEED = 200.0
const JUMP_FORCE = -450.0

var player: Node = null
var target_detected := false

@onready var jump_area = $JumpArea

@onready var idle_sprite = $cube_sprite
@onready var angry_sprite = $angry_sprite
@onready var flight_sprite = $flight_sprite
@onready var ready_to_jump_sprite = $ready_to_jump_sprite

@onready var animation = $AnimationPlayer

enum state {
	IDLE,
	ANGRY,
	IN_FLiGHT
}

var cur_state = state.IDLE

func _ready():
	pass

func _physics_process(delta):
	
	# Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if cur_state == state.ANGRY:
		handle_angry()
	elif cur_state == state.IDLE:
		handle_idle() 
	elif cur_state == state.IN_FLiGHT:
		handle_flight()
	
	
		
	
	# Если видит игрока — прыгнуть в его сторону
	if target_detected and is_on_floor():
		cur_state = state.ANGRY
	elif !target_detected and is_on_floor():
		cur_state = state.IDLE

	move_and_slide()


func jump_towards_player():
	if not player:
		return
	# Определяем сторону прыжка
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * SPEED
	velocity.y = JUMP_FORCE   # прыжок
	cur_state = state.IN_FLiGHT
	

func _on_jump_area_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		player = body
		target_detected = true
		cur_state = state.IN_FLiGHT


func _on_jump_area_body_exited(body: Node2D) -> void:
	if body == player:
		target_detected = false
		player = null


func handle_angry():
	flight_sprite.visible = false
	idle_sprite.visible = false
	angry_sprite.visible = true
	## TODO: Тут добавить ожидание когда проиграет анимка и потом делаем state.flight
	if !animation.is_playing():
		#animation.play("jump")
		#await animation.animation_finished
		#ready_to_jump_sprite.visible = false
		#print("animation played!")
		jump_towards_player()
	
func handle_idle():
	flight_sprite.visible = false
	idle_sprite.visible = true
	angry_sprite.visible = false
	velocity = Vector2(0, 0)

func handle_flight():
	flight_sprite.visible = true
	idle_sprite.visible = false
	angry_sprite.visible = false
