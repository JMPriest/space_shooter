extends Area2D

signal died
signal shield_changed

@export var speed = 150
@export var cooldown = 0.25
@export var bullet_scene : PackedScene

var can_shoot = true

@export var max_shield = 10
# we want to call the set_shield() function 
# whenever the shield variable has its value set
var shield = max_shield:
	set = set_shield

@onready var screensize = get_viewport_rect().size


func set_shield(value):
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield <= 0:
		hide()
		died.emit()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _ready():
	start()
	
func start()-> void:
	position = Vector2(screensize.x / 2, screensize.y - 64)
	$GunCoolDown.wait_time = cooldown
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
var mouse_left_holding: bool = false

func _input(event: InputEvent) -> void:
	var is_moving = event is InputEventMouseMotion
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			mouse_left_holding = true
		if event.is_released() and mouse_left_holding:
			mouse_left_holding = false
		
	if not (is_moving or mouse_left_holding):
		return

	if mouse_left_holding:
		shoot()
	
	if is_moving:
		var relative = event.relative

		if relative.x > 0:
			$Ship.frame = 2
			$Ship/Boosters.animation = "right"
		elif relative.x < 0:
			$Ship.frame = 0
			$Ship/Boosters.animation = "left"
		else:
			$Ship.frame = 1
			$Ship/Boosters.animation = "forward"
		position += relative
		position = position.clamp(Vector2(8, 8), screensize - Vector2(8, 8))
	
func shoot():
	if not can_shoot:
		return
		
	can_shoot = false
	$GunCoolDown.start()
	if is_visible():
		var b = bullet_scene.instantiate()
		get_tree().root.add_child(b)
		b.start(position + Vector2(0, -8))
		var tween = create_tween().set_parallel(false)
		tween.tween_property($Ship, "position:y", 1, 0.1)
		tween.tween_property($Ship, "position:y", 0, 0.05)


func _on_gun_cool_down_timeout() -> void:
	can_shoot = true


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.explode()
		shield -= max_shield / 2
