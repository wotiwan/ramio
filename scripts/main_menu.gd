extends Control

# Ссылки на узлы 
@onready var settings: Panel = $Settings
@onready var master_slider: HSlider = $Settings/VBoxContainer/VBoxContainer/MasterVolume_slider
@onready var music_slider: HSlider = $Settings/VBoxContainer/VBoxContainer2/MusicVolume_slider
@onready var fullscreen_check: CheckButton = $Settings/VBoxContainer/CheckButton

# Путь к файлу сохранения настроек (в папке пользователя)
const CONFIG_PATH: String = "user://settings.cfg"

# Объект ConfigFile для чтения/записи
var config: ConfigFile = ConfigFile.new()

var settings_opened: bool = false


func _ready() -> void:
	# Загружаем настройки, если файл существует
	var err = config.load(CONFIG_PATH)
	
	# Значения по умолчанию
	var default_master: float = 1.0     # 100%
	var default_music: float = 1.0
	var default_fullscreen: bool = false
	
	# Читаем сохранённые значения или используем дефолтные
	var master_vol: float = config.get_value("audio", "master_volume", default_master) if err == OK else default_master
	var music_vol: float = config.get_value("audio", "music_volume", default_music) if err == OK else default_music
	var fullscreen: bool = config.get_value("display", "fullscreen", default_fullscreen) if err == OK else default_fullscreen
	
	# Устанавливаем значения на элементы интерфейса
	master_slider.value = master_vol
	music_slider.value = music_vol
	fullscreen_check.button_pressed = fullscreen
	
	# Применяем настройки сразу при запуске
	_apply_master_volume(master_vol)
	_apply_music_volume(music_vol)
	_apply_fullscreen(fullscreen)
	
	# Подключаем сигналы изменения слайдеров
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	
	# Сигнал toggled для CheckButton должен быть подключён в редакторе к функции _on_check_button_toggled
	# (если не подключён — подключи вручную в редакторе Godot)


# Применение громкости Master
func _apply_master_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


# Применение громкости Music (нужна аудиошина с именем "Music")
func _apply_music_volume(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	else:
		push_warning("Аудиошина 'Music' не найдена! Добавь её в Project Settings → Audio → Buses")


# Применение полноэкранного режима
func _apply_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Сохранение всех настроек в файл
func _save_settings() -> void:
	config.set_value("audio", "master_volume", master_slider.value)
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("display", "fullscreen", fullscreen_check.button_pressed)
	var err = config.save(CONFIG_PATH)
	if err != OK:
		push_error("Не удалось сохранить настройки! Код ошибки: " + str(err))


# Вызывается при изменении слайдера Master
func _on_master_volume_changed(value: float) -> void:
	_apply_master_volume(value)
	_save_settings()


# Вызывается при изменении слайдера Music
func _on_music_volume_changed(value: float) -> void:
	_apply_music_volume(value)
	_save_settings()


# Вызывается при переключении CheckButton 
func _on_check_button_toggled(toggled_on: bool) -> void:
	_apply_fullscreen(toggled_on)
	_save_settings()



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc_button_pressed"):
		if settings_opened:
			settings.visible = false
			settings_opened = false
		else:
			get_tree().quit()


func _on_play_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/levels_menu.tscn")


func _on_settings_button_button_down() -> void:
	settings_opened = true
	settings.visible = true


func _on_exit_button_button_down() -> void:
	get_tree().quit()


func _on_exit_settings_button_button_down() -> void:
	settings.visible = false
	settings_opened = false 
