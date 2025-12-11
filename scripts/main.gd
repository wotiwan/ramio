extends Node2D

@onready var player = $Player
@onready var lose_menu = $CanvasLayer/LoseMenu
@onready var win_menu = $CanvasLayer/WinMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("win_signal", _on_win)
	player.connect("loose_signal", _on_loose)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_win():
	win_menu.set_active()

func _on_loose():
	lose_menu.set_active()
	player.queue_free()
