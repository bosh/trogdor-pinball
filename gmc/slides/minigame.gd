extends MPFSlide

@export var player_speed = 300 # pixels/second
var screen_size # window size
var trogdor_facing = "right"
var continuous_action = "stop"

# STANDARD NODE

func _ready():
	screen_size = get_viewport_rect().size
	$left.visible = false
	$right.visible = false
	$player/CollisionShape2D.disabled = false
	$player/firebreath.visible = false
	$player/TrogdorSprite.play("idle")
	$GameTimer.start()
	trogdor_facing = "right"
	$player.position = $PlayerStart.position

func _process(delta):
	$left.visible = continuous_action == "left"
	$right.visible = continuous_action == "right"
	move_player(delta)

# SIGNAL BINDINGS

func _on_player_body_entered(body):
	if body == $Heart:
		$Heart/CollisionShape2D.set_deferred("disabled", true)
		$Heart/HeartAnimation.play()
		print("Heart captured")
		activate_flames()
		MPF.server.send_event("minigame_heart_capture")
	if body == $Coins:
		$Coins.visible = false
		$Coins/CollisionShape2D.set_deferred("disabled", true)
		print("Coins captured")
		activate_flames()
		MPF.server.send_event("minigame_coin_capture")

func _on_heart_animation_animation_finished():
	$Heart.queue_free()

func _on_game_timer_timeout():
	MPF.server.send_event("minigame_timer_expired")
	# TODO swap to end content

# CUSTOM EVENT ACTION HOOKS (PUBLIC REMOTE)

func action_left(_settings, _kwargs):
	print("Minigame Action Received - Left")
	trogdor_facing = "left"
	continuous_action = "left"

func action_right(_settings, _kwargs):
	print("Minigame Action Received - Right")
	continuous_action = "right"
	trogdor_facing = "right"

func action_start(_settings, _kwargs):
	print("Minigame Action Received - Start")
	if continuous_action == "stop":
		continuous_action = trogdor_facing
	else:
		continuous_action = "stop"

# CUSTOM PUBLIC FNS

func stop_player():
	continuous_action = "stop"
	$player/TrogdorSprite.play("idle")

func move_player(delta):
	var direction = _get_continuous_velocity()

	if direction < 0:
		trogdor_facing = "left"
		$player/TrogdorSprite.play("walk_right")
	elif direction > 0:
		trogdor_facing = "right"
		$player/TrogdorSprite.play("walk_right")
	else:
		stop_player()

	var player = $player
	var abs_x_position = abs(player.position.x)
	var abs_x_scale = abs(player.scale.x)

	if trogdor_facing == "left":
		player.scale.x = - abs_x_scale
	elif trogdor_facing == "right":
		player.scale.x = abs_x_scale

	$player.position.x = $player.position.x + (direction * player_speed * delta)
	_check_edges()

func activate_flames():
	$player/firebreath.visible = true
	$player/firebreath/FlameSprite.play()

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

func _on_flame_sprite_animation_finished():
	$player/firebreath.visible = false
