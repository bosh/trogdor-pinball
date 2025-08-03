extends MPFSlide

@export var player_speed = 10 # pixels/second
var screen_size # window size
var trogdor_facing = "right"
var continuous_action = "stop"

# STANDARD NODE

func _ready():
	screen_size = get_viewport_rect().size
	trogdor_facing = "right"
	$left.visible = false
	$right.visible = false
	$player/CollisionShape2D.disabled = false
	$GameTimer.start()
	$player/FlameSpriteLeft.visible = false
	$player/FlameSpriteRight.visible = false
	$player.position = $PlayerStart.position

func _process(delta):
	$left.visible = continuous_action == "left"
	$right.visible = continuous_action == "right"
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
	trogdor_facing = "left"
	continuous_action = "left"


func action_right(_settings, _kwargs):
	print("Minigame Action - Right")
	continuous_action = "right"
	trogdor_facing = "right"

func action_start(_settings, _kwargs):
	print("Minigame Action - Start")
	if continuous_action == "stop":
		continuous_action = trogdor_facing
	else:
		continuous_action = "stop"

# CUSTOM PUBLIC FNS

func stop_player():
	continuous_action = "stop"
	$player/TrogdorSprite.stop()

func move_player(delta):
	var direction = _get_continuous_velocity()

	if direction < 0:
		trogdor_facing = "left"
		$player/TrogdorSprite.play("walk_left")
	elif direction > 0:
		trogdor_facing = "right"
		$player/TrogdorSprite.play("walk_right")
	else:
		stop_player()

	$player.move_local_x(direction * player_speed, false)
	_check_edges()

func activate_flames():
	# TODO changing direction should swap the animation direction. Maybe position and scale should be changed instead
	if trogdor_facing == "left": # TODO this is actually different than action because frozen still has facing...
		$player/FlameSpriteLeft.visible = true
		$player/FlameSpriteLeft.play()
	else:
		$player/FlameSpriteRight.visible = true
		$player/FlameSpriteRight.play()

# CUSTOM PRIVATE FNS

func _get_continuous_velocity():
	if continuous_action == "left":
		return -1
	if continuous_action == "right":
		return 1
	return 0

func _check_edges():
	var clamped_position = $player.position.clamp(Vector2.ZERO, screen_size)
	if $player.position != clamped_position:
		print("Minigame player hit edge")
		$player.position = clamped_position
		stop_player()

func _on_flame_sprite_right_animation_finished():
	$player/FlameSpriteRight.visible = false

func _on_flame_sprite_left_animation_finished():
	$player/FlameSpriteLeft.visible = false
