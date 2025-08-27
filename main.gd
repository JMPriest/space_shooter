extends Node2D

var enemy = preload("res://enemy.tscn")
@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver

var score = 0
var playing = false

func _ready():
	game_over.hide()
	start_button.show()
	var tween = create_tween().set_loops().set_parallel(false).set_trans(Tween.TRANS_SINE)
	var tween2 = create_tween().set_loops().set_parallel(false).set_trans(Tween.TRANS_BACK)

func spawn_enemies():
	for x in range(9):
		for y in range(3):
			var e = enemy.instantiate()
			var pos = Vector2(x * (16 + 8) + 24, 16 * 4 + y * 16)
			add_child(e)
			e.start(pos)
			e.died.connect(_on_enemy_died)


func _on_enemy_died(value) -> void:
	score += value
	$CanvasLayer/UI.update_score(score)

func _on_start_pressed() -> void:
	start_button.hide()
	game_over.hide()
	new_game()

func new_game():
	score = 0
	$CanvasLayer/UI.update_score(score)
	$Player.shield = $Player.max_shield
	$Player.start()
	spawn_enemies()
	playing = true

func _on_player_died() -> void:
	playing = false
	get_tree().call_group("enemies", "queue_free")
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()

func _process(_delta):
	if get_tree().get_nodes_in_group("enemies").size() == 0 and playing:
		spawn_enemies()
