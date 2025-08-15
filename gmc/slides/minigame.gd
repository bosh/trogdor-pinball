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
	var direction = _get_continuous_velocity()
	$player.move_and_collide(Vector2((direction * player_speed * delta), 0))

# SIGNAL BINDINGS

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
	$player/TrogdorSprite.flip_h = true
	$player/TrogdorSprite.play("walk")

func action_right(_settings, _kwargs):
	print("Minigame Action Received - Right")
	trogdor_facing = "right"
	continuous_action = "right"
	$player/TrogdorSprite.flip_h = false
	$player/TrogdorSprite.play("walk")

func action_start(_settings, _kwargs):
	print("Minigame Action Received - Start")
	if continuous_action == "stop":
		continuous_action = trogdor_facing
		$player/TrogdorSprite.flip_h = (trogdor_facing == "left")
		$player/TrogdorSprite.play("walk")
	else:
		stop_player()

# CUSTOM PUBLIC FNS

func stop_player():
	continuous_action = "stop"
	$player/TrogdorSprite.play("idle")

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

func _on_flame_sprite_animation_finished():
	$player/firebreath.visible = false

func _on_trogdor_sprite_animation_finished():
	if $player/TrogdorSprite.animation == "flex":
		$player/TrogdorSprite.play("idle")
		activate_flames()

func _on_coins_body_entered(_body):
	$Coins/CollisionShape2D.set_deferred("disabled", true)
	print("Coins captured")
	continuous_action = "stop"
	$player/TrogdorSprite.play("flex")
	$Coins.queue_free()
	MPF.server.send_event("minigame_coin_capture")

func _on_heart_body_entered(_body):
	$Heart/CollisionShape2D.set_deferred("disabled", true)
	$Heart/HeartAnimation.play()
	print("Heart captured")
	activate_flames()
	MPF.server.send_event("minigame_heart_capture")
