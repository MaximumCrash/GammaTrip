extends CanvasItem
class_name HitFlashVFX

@export var hit_flash: CanvasItem
@export var hit_flash_duration_ms := 250
var last_hit_time := 0.0

func _process(delta: float) -> void:
	var elapsed := Time.get_ticks_msec() - last_hit_time
	var flash_active := elapsed <= hit_flash_duration_ms
	hit_flash.material.set_shader_parameter("active", flash_active)

func play() -> void:
	last_hit_time = Time.get_ticks_msec()
