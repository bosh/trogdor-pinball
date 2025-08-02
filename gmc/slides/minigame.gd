extends MPFSlide

@export var player_speed = 10 # pixels/second
var screen_size # window size

# STANDARD NODE

func _ready():
	screen_size = get_viewport_rect().size
	$left.visible = false
	$right.visible = false
	$player/CollisionShape2D.disabled = false
	$GameTimer.start()
	$player/FlameSpriteLeft.visible = false
	$player/FlameSpriteRight.visible = false
	$player.start($PlayerStart.position)

func _process(delta):
	move_player(delta)

# SIGNAL BINDINGS

func _on_player_body_entered(body):
	$player/CollisionShape2D.set_deferred("disabled", true)
	if body == $Heart:
		$Heart/HeartAnimation.play()
		print("Heart captured")
		activate_flames()
		# TODO report heart capture to MPF

func _on_heart_animation_animation_finished():
	$Heart.queue_free()

func _on_game_timer_timeout():
	pass # TODO report game over to MPF and then swap to end content

# CUSTOM EVENT ACTION HOOKS (PUBLIC REMOTE)

func action_left(_settings, _kwargs):
	print("Minigame Action - Left")
	$left.visible = true
	$right.visible = false

func action_right(_settings, _kwargs):
	print("Minigame Action - Right")
	$left.visible = false
	$right.visible = true

func action_start(_settings, _kwargs):
	print("Minigame Action - Start")
	$left.visible = !$left.visible
	$right.visible = !$right.visible

# CUSTOM PUBLIC FNS

func stop_player():
	$left.visible = false
	$right.visible = false
	$player/TrogdorSprite.stop()

func move_player(delta):
	var direction = _get_action_direction()

	if direction < 0:
		$player/TrogdorSprite.play("walk_left")
	elif direction > 0:
		$player/TrogdorSprite.play("walk_right")
	else:
		stop_player()

	$player.move_local_x(direction * player_speed, false)
	_check_edges()

func activate_flames():
	# TODO changing direction should swap the animation direction. Maybe position and scale should be changed instead
	var facing = _get_action_direction()
	if facing <= 0: # TODO this is actually different than action because frozen still has facing...
		$player/FlameSpriteLeft.visible = true
		$player/FlameSpriteLeft.play()
	elif facing > 0:
		$player/FlameSpriteRight.visible = true
		$player/FlameSpriteRight.play()

# CUSTOM PRIVATE FNS

func _get_action_direction():
	if $left.visible && !$right.visible:
		return -1
	if $right.visible && !$left.visible:
		return 1
	return 0

func _check_edges():
	var clamped_position = $player.position.clamp(Vector2.ZERO, screen_size)
	if $player.position != clamped_position:
		$player.position = clamped_position
		stop_player()
		print("Minigame player hit edge")

func _on_flame_sprite_right_animation_finished():
	$player/FlameSpriteRight.visible = false

func _on_flame_sprite_left_animation_finished():
	$player/FlameSpriteLeft.visible = false
