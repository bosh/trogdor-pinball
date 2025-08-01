extends MPFSlide

func _ready():
	$left.visible = false
	$right.visible = false

func action_left(_settings, _kwargs):
	$left.visible = true
	$right.visible = false

func action_right(_settings, _kwargs):
	$left.visible = false
	$right.visible = true

func action_start(_settings, _kwargs):
	$left.visible = !$left.visible
	$right.visible = !$right.visible
