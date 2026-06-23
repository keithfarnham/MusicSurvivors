extends SubViewportContainer

#spectrum analysis code from https://godotshaders.com/shader/spectrum-analyzer/

@onready var spriteMaterial = $SubViewport/SubViewportSprite2D.material

var audio_node : AudioController
var setup_complete : bool = false

func _on_fft_update(fft):
	spriteMaterial.set_shader_parameter("freq_data", fft)

func _process(delta):
	# this is done in process to ensure AudioController is instantiated
	var audio_node = get_tree().get_first_node_in_group("AudioController") as AudioController
	if not setup_complete and audio_node != null:
		setup_complete = true
		audio_node.fft_update.connect(_on_fft_update)
