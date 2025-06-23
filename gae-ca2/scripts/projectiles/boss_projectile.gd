extends Area2D
class_name BossProjectile

var direction: Vector2
var speed: float
var damage: float
var lifetime: float = 5.0  # Projectile disappears after 5 seconds

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

#func _ready():
	#pass
	# Connect collision signals
	#body_entered.connect(_on_body_entered)
	#area_entered.connect(_on_area_entered)
	
	# Start lifetime timer
	#adjust_direction()
	#var timer = Timer.new()
	#add_child(timer)
	#timer.wait_time = lifetime
	#timer.one_shot = true
	#timer.start()
	#timer.timeout.connect(_on_lifetime_expired)

func initialize(proj_direction: Vector2, proj_speed: float, proj_damage: float):
	direction = proj_direction
	speed = proj_speed
	damage = proj_damage
	
	# Rotate sprite to face movement direction
	#rotation = direction.angle()
	
func ranged_attack(direction: Vector2, target_position: Vector2) -> void:
	var player_start_pos = Global.player.global_position

	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	# Nach Ankunft 1 Sekunde warten
	#await get_tree().create_timer(0.1).timeout

	# Spielerposition überprüfen und ggf. Schaden zufügen
	if Global.player.global_position.distance_to(player_start_pos) <= 15:
		Global.player.take_damage(damage)

	queue_free()


#func _physics_process(delta):
	## Move projectile
	#global_position += direction * speed * delta

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


func _on_lifetime_expired():
	# Projectile expires naturally
	queue_free()
	

func adjust_direction() -> void:
	var projectile_flying = true
	while projectile_flying == true:
		var direction = (Global.player.global_position - global_position).normalized()
		global_position += direction * 7
		
		if Global.player.global_position.distance_to(global_position) <= 20:
			# * Global.player.get_stat("movement_speed") for the calculation below
			var player_position_prediction = (get_global_mouse_position() - Global.player.global_position).normalized()
			global_position += player_position_prediction * 7
			await get_tree().create_timer(1).timeout
			if Global.player.global_position.distance_to(global_position) <= 20:
				Global.player.take_damage(20)
				projectile_flying = false
			queue_free()
		await get_tree().create_timer(0.1).timeout
	
	
	

func create_hit_effect():
	# Create visual/audio effects when projectile hits
	print("Projectile impact effect")
