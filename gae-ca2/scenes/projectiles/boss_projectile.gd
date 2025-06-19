extends Area2D
class_name BossProjectile

var direction: Vector2
var speed: float
var damage: float
var lifetime: float = 5.0  # Projectile disappears after 5 seconds

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	# Connect collision signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Start lifetime timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_lifetime_expired)

func initialize(proj_direction: Vector2, proj_speed: float, proj_damage: float):
	direction = proj_direction
	speed = proj_speed
	damage = proj_damage
	
	# Rotate sprite to face movement direction
	rotation = direction.angle()

func _physics_process(delta):
	# Move projectile
	global_position += direction * speed * delta

func _on_body_entered(body):
	# Check if it hit the player
	if body == Global.player:
		# Deal damage to player
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Projectile hit player for ", damage, " damage")
		
		# Create hit effect (optional)
		create_hit_effect()
		
		# Destroy projectile
		queue_free()
	
	# Check if it hit a wall or obstacle
	elif body.has_method("has_method") == false:  # Static bodies like walls
		# Create hit effect
		create_hit_effect()
		queue_free()

func _on_area_entered(area):
	# Handle collision with other areas if needed
	pass

func _on_lifetime_expired():
	# Projectile expires naturally
	queue_free()

func create_hit_effect():
	# Create visual/audio effects when projectile hits
	print("Projectile impact effect")
