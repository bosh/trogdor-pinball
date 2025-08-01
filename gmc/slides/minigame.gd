extends MPFSlide

@export var player_speed = 10 # pixels/second
var screen_size # window size
signal hit

func _ready():
	screen_size = get_viewport_rect().size
	$left.visible = false
	$right.visible = false
	$player/CollisionShape2D.disabled = false

func _process(delta):
	var move_direction = 0
	if $left.visible && !$right.visible:
		move_direction = -1
		$player/AnimatedSprite2D.play("walk_left")
	if $right.visible && !$left.visible:
		move_direction = 1
		$player/AnimatedSprite2D.play("walk_right")
	if move_direction == 0:
		$player/AnimatedSprite2D.stop()
	else:
		$player.move_local_x(move_direction * player_speed, false)
		$player.position = $player.position.clamp(Vector2.ZERO, screen_size)

func action_left(_settings, _kwargs):
	$left.visible = true
	$right.visible = false

func action_right(_settings, _kwargs):
	$left.visible = false
	$right.visible = true

func action_start(_settings, _kwargs):
	$left.visible = !$left.visible
	$right.visible = !$right.visible


func _on_player_body_entered(body):
	hit.emit()
	$player/CollisionShape2D.set_deferred("disabled", true)
