extends CanvasLayer

signal start_game


func show_message(text, duration):
	$MessageTimer.wait_time = duration
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over", 1.0)

	await $MessageTimer.timeout

	$Message.text = "Gamma Trip"
	$Message.show()

	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
