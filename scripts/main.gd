extends Node2D

@onready var player = $Player
@onready var lose_menu = $CanvasLayer/LoseMenu
@onready var win_menu = $CanvasLayer/WinMenu

@onready var yellow_box = $Static/Yellow2

@onready var red_key = $Static/KeyRed # Ключ на подбор
var red_key_collected: bool = false
@onready var red_key2 = $Static/KeyRed2 # Ключ в скважине
@onready var red_lock = $Static/ZamokRed
var red_lock_unlocked: bool = false

@onready var door = $Static/Door



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("win_signal", _on_win)
	player.connect("loose_signal", _on_loose)
	
	player.connect("static_collision", _on_collision)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_win():
	win_menu.set_active()

func _on_loose():
	lose_menu.set_active()
	player.queue_free()


func _on_collision(collider):
	if "Yellow2" in collider.name:
		if !red_key_collected:
			animate_item_collect(red_key)
			red_key_collected = true
			animate_block(collider, false)
	
	if "Grass" in collider.name:
		animate_block(collider, true)

func animate_block(collider, to_destroy: bool):
	collider.get_child(1).play("break")  # Обращаемся к анимейшн плееру
	if to_destroy:
		collider.get_child(2).disabled = true  # Обращаемся к колижен шейп
		await collider.get_child(1).animation_finished
		collider.queue_free()

func animate_item_collect(item: StaticBody2D):
	item.get_child(1).play("collect")  # Обращаемся к анимейшн плееру

func animate_key_entered(item: StaticBody2D):
	item.get_child(1).play("key_entered")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		if red_key_collected and !red_lock_unlocked:
			animate_key_entered(red_key2)
			red_lock_unlocked = true
			door.get_child(0).visible = false
			door.get_child(3).set_deferred("disabled", true)
			
			
		else:
			print("Сначала найди ключ, дебил!")


func _on_win_area_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		win_menu.set_active()
