extends "res://scripts/enemies/enemy_base.gd"

func _ready():
	super._ready()

# Overrides enemy_base.gd
func attack():
	enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
	enemy_animations.play("attack")
	attack_cooldown_timer = get_stat("attack_cooldown")
	await enemy_animations.animation_finished
	enemy_animations.play("idle")

# Overrides enemy_base.gd
func _on_attack_frame_changed():
	if enemy_animations.animation == "attack" and enemy_animations.frame == 10:
		var distance = center.global_position.distance_to(Global.player.get_center_position())
		if distance <= stats.get_stat("attack_range"):
			Global.player.take_damage(get_stat("attack_damage"))

# Overrides enemy_base.gd
func get_center_position():
	return center.global_position
	
func move_towards_player(delta: float, distance_to_player: float):
	# If in attack range and cooldown 0
	if distance_to_player <= get_stat("attack_range") and attack_cooldown_timer <= 0.0:
		change_state(EnemyState.ATTACK)
		return
	# Only move if not in attack range
	if distance_to_player > get_stat("attack_range") and attack_cooldown_timer <= 0.0:
		enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
		enemy_animations.play("move")
		var direction = (Global.player.get_center_position() - global_position).normalized()
		velocity = direction * get_stat("movement_speed")
	else:
		# Stop moving when in attack range but cooldown >= 0
		enemy_animations.flip_h = Global.player.get_center_position().x < global_position.x
		enemy_animations.play("idle")
		velocity = Vector2.ZERO
