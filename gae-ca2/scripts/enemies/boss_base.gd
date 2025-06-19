extends Enemy
class_name Boss

enum BossState { WALK, RANGED_ATTACK, MELEE_ATTACK, DEAD }

@export var projectile_scene: PackedScene
@export var ranged_attack_range: float = 200.0
@export var ranged_attack_damage: float = 15.0
@export var ranged_attack_cooldown: float = 2.0
@export var projectile_speed: float = 300.0
@export var melee_attack_range: float = 50.0
@export var melee_attack_damage: float = 25.0
@export var melee_attack_cooldown: float = 1.5

var ranged_cooldown_timer: float = 0.0
var melee_cooldown_timer: float = 0.0
var boss_current_state: BossState = BossState.WALK

func _ready():
	super._ready()  # Call parent _ready()
	health.set_healthbar_position(global_position + Vector2(-15,100))	

	# Override some base enemy values for boss
	max_health *= 3  # Bosses have more health
	health.initialize_health(max_health)
	
	print("Boss initialized with ", max_health, " health")

func _physics_process(delta):
	# Update cooldown timers
	if ranged_cooldown_timer > 0.0:
		ranged_cooldown_timer -= delta
	if melee_cooldown_timer > 0.0:
		melee_cooldown_timer -= delta
		
	if Global.player == null:
		push_error("Global.player is null")
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var distance_to_player = global_position.distance_to(Global.player.global_position)
	
	match boss_current_state:
		BossState.WALK:
			boss_movement_logic(delta, distance_to_player)
		BossState.RANGED_ATTACK:
			perform_ranged_attack(delta, distance_to_player)
		BossState.MELEE_ATTACK:
			perform_melee_attack(delta, distance_to_player)
		BossState.DEAD:
			velocity = Vector2.ZERO
			
	move_and_slide()
	
func boss_movement_logic(delta: float, distance_to_player: float):
	# Decide which attack to use based on distance and cooldowns
	if distance_to_player <= melee_attack_range and melee_cooldown_timer <= 0.0:
		change_boss_state(BossState.MELEE_ATTACK)
		return
	elif distance_to_player <= ranged_attack_range and distance_to_player > melee_attack_range and ranged_cooldown_timer <= 0.0:
		change_boss_state(BossState.RANGED_ATTACK)
		return
	
	# Move towards player if not in any attack range
	if distance_to_player > melee_attack_range:
		var direction = (Global.player.global_position - global_position).normalized()
		velocity = direction * movement_speed * 0.8  # Bosses move slightly slower
	else:
		velocity = Vector2.ZERO

func perform_ranged_attack(delta: float, distance_to_player: float):
	velocity = Vector2.ZERO
	
	# Aim and throw projectile at player
	throw_projectile_at_player()
	
	# Set cooldown and return to walking
	ranged_cooldown_timer = ranged_attack_cooldown
	change_boss_state(BossState.WALK)

func perform_melee_attack(delta: float, distance_to_player: float):
	velocity = Vector2.ZERO
	
	# Perform melee attack
	if distance_to_player <= melee_attack_range:
		deal_melee_damage()
	
	# Set cooldown and return to walking
	melee_cooldown_timer = melee_attack_cooldown
	change_boss_state(BossState.WALK)

func throw_projectile_at_player():
	if not projectile_scene:
		print("No projectile scene assigned to boss!")
		return
		
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	# Position projectile at boss location
	projectile.global_position = global_position
	
	# Calculate direction to player with some prediction
	var target_position = predict_player_position()
	var direction = (target_position - global_position).normalized()
	
	# Set projectile properties
	if projectile.has_method("initialize"):
		projectile.initialize(direction, projectile_speed, ranged_attack_damage)
	
	print("Boss threw projectile at player")

func predict_player_position() -> Vector2:
	# Simple prediction: aim slightly ahead of player based on their velocity
	var player_velocity = Vector2.ZERO
	if Global.player.has_method("get_velocity"):
		player_velocity = Global.player.get_velocity()
	elif Global.player.has_property("velocity"):
		player_velocity = Global.player.velocity
	
	# Predict where player will be in 0.5 seconds
	var prediction_time = 0.5
	return Global.player.global_position + (player_velocity * prediction_time)

func deal_melee_damage():
	if Global.player.has_method("take_damage"):
		Global.player.take_damage(melee_attack_damage)
		print("Boss dealt ", melee_attack_damage, " melee damage to player")

func change_boss_state(new_state: BossState):
	if boss_current_state == new_state:
		return
		
	boss_current_state = new_state
	
	match new_state:
		BossState.RANGED_ATTACK:
			print("Boss entering ranged attack state")
		BossState.MELEE_ATTACK:
			print("Boss entering melee attack state")

			attack()
		BossState.DEAD:
			die()

## Override parent attack method to use boss-specific logic
#func attack():
	## This method is called from parent, but we handle attacks differently
	## So we can leave this empty or redirect to our boss logic
	#pass


# Override die method to add boss-specific death behavior
func die():
	print("Boss defeated!")
	boss_current_state = BossState.DEAD
	# Add boss death effects here (screen shake, special loot, etc.)
	super.die()
