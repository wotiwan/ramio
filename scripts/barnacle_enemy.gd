extends CharacterBody2D

const SPEED = 450.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800.0
enum State {IDLE, COMPRESSED}

@onready var animation = get_node("AnimationPlayer")
#@onready var sprite = get_node("SlimeSprite")

var current_state: State = State.IDLE

func set_state(new_state: State):
	current_state = new_state

func _ready() -> void:
	set_state(State.IDLE)

func handle_idle():
	pass
	#animation.play("idle")

func handle_pressed():
	print("Pressed!!")
	#animation.play("pressed")

func handle_collisions(delta: float):
	var platform = null
	var collision_count = get_slide_collision_count()
	#print(collision_count)
	for c in collision_count:
		var collision = get_slide_collision(c)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if "Player" in collider.name:
			
			set_state(State.COMPRESSED)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle()
		State.COMPRESSED:
			handle_pressed()
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	handle_collisions(delta)
	move_and_slide()
