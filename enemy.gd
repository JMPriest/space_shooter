extends Area2D

var start_pos = Vector2.ZERO
var speed = 0
signal died

@onready var screensize  = get_viewport_rect().size
var bullet_scene = preload("res://enemy_bullet.tscn")

func start(pos):
	speed = 0
	position = Vector2(pos.x, -pos.y)
	start_pos = pos
	await get_tree().create_timer(randf_range(0.25, 0.55)).timeout
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", start_pos.y, 1.4)
	await tween.finished
	$MoveTimer.wait_time = randf_range(5, 20)
	$MoveTimer.start()
	$ShootTimer.wait_time = randf_range(4, 20)
	$ShootTimer.start()
	
func _process(delta):
	position.y += speed * delta
	if position.y > screensize.y + 32:
		start(start_pos)
		
func explode():
	speed = 0
	$AnimationPlayer.play("explode")
	set_deferred("monitoring", false)
	# send the score: 5 to main
	died.emit(5)
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_shoot_timer_timeout() -> void:
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position)
	$ShootTimer.wait_time = randf_range(4, 20)
	$ShootTimer.start()


func _on_move_timer_timeout() -> void:
	speed = randf_range(75, 100)
