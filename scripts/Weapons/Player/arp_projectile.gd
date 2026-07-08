extends Projectile

class_name ArpProjectile

@onready var particles = $collisionParticles as GPUParticles2D
var default_gradient = preload("res://resources/textures/snare_1d_gradient.tres")
var colliding_gradient = preload("res://resources/textures/snare_collision_1d_gradient.tres")

@export var accel_default : float = 0.1
@export var accel_collision : float = 0.5

func _physics_process(delta):
	#Log.print("[SnareProjectile] %s is processing" % [name])
	position += angle*speed*delta

func _on_projectile_spawn():
	super()
	#print("_on_projectile_spawn override hit")

func _ready():
	angle = global_position.direction_to(target_pos)
	rotation = angle.angle() + deg_to_rad(90)

func _on_arp_hitbox_area_entered(area):
	# turn on hit particles
	particles.emitting = true
