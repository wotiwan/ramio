extends CharacterBody2D

@export var speed: float = 100.0
@export var left_limit: float = -200.0
@export var right_limit: float = 200.0

@onready var sprite = get_node("Sprite2D")

var direction: int = 1  # 1 – вправо, -1 – влево

func _physics_process(delta: float) -> void:
	# Падение
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Горизонтальное движение
	velocity.x = direction * speed

	move_and_slide()

	# Проверяем выход за границы
	if global_position.x < left_limit:
		direction = 1   # идём вправо
		sprite.flip_h = true
	elif global_position.x > right_limit:
		direction = -1  # идём влево
		sprite.flip_h = false
