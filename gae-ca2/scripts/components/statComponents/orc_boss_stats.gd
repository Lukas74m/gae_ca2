extends EnemyStatComponent

# base stats from the entity
var boss_base_stats = {
	"melee_attack_damage": 0,
	"melee_attack_range": 0,
	"melee_attack_cooldown": 0,
	"ranged_attack_damage": 0,
	"ranged_attack_range": 0,
	"ranged_attack_cooldown": 0,
	"projectile_speed": 0,
	"melee_charge_cooldown": 0,
	"dash_range": 0,
	"dash_speed": 0,
	"dash_duration": 0,
	"dash_cooldown": 0,
	"initial_dash_delay": 0,
}

# additive modifiers from the entity
var boss_additive_mods = {
	"melee_attack_damage": 0,
	"melee_attack_cooldown": 0,
	"ranged_attack_damage": 0,
	"ranged_attack_cooldown": 0,
}

# multiplicative modifiers from the entity
var boss_multiplicative_mods = {
	"melee_attack_damage": 1,
	"melee_attack_range": 1,
	"ranged_attack_damage": 1,
	"ranged_attack_range": 1,
}

# Overrides parent
func initialize_stats(enemy_resource: EnemyResource):
	super.initialize_stats(enemy_resource)
	
	boss_base_stats["melee_attack_damage"] = enemy_resource.melee_attack_damage
	boss_base_stats["melee_attack_range"] = enemy_resource.melee_attack_range
	boss_base_stats["melee_attack_cooldown"] = enemy_resource.melee_attack_cooldown
	boss_base_stats["ranged_attack_damage"] = enemy_resource.ranged_attack_damage
	boss_base_stats["ranged_attack_range"] = enemy_resource.ranged_attack_range
	boss_base_stats["ranged_attack_cooldown"] = enemy_resource.ranged_attack_cooldown
	boss_base_stats["projectile_speed"] = enemy_resource.projectile_speed
	boss_base_stats["melee_charge_cooldown"] = enemy_resource.melee_charge_cooldown
	boss_base_stats["dash_range"] = enemy_resource.dash_range
	boss_base_stats["dash_speed"] = enemy_resource.dash_speed
	boss_base_stats["dash_duration"] = enemy_resource.dash_duration
	boss_base_stats["dash_cooldown"] = enemy_resource.dash_cooldown
	boss_base_stats["initial_dash_delay"] = enemy_resource.initial_dash_delay
	
# Override get_stat to handle boss stats
func get_stat(stat_name: String):
	# Check if it's a boss-specific stat
	if boss_base_stats.has(stat_name):
		var base = boss_base_stats.get(stat_name, 0)
		var add = boss_additive_mods.get(stat_name, 0)
		var mult = boss_multiplicative_mods.get(stat_name, 1)
		return (base + add) * mult
	else:
		# Use parent implementation for regular stats
		return super.get_stat(stat_name)

# Override apply_add_modifier for boss stats
func apply_add_modifier(stat_name: String, value: float):
	if boss_additive_mods.has(stat_name):
		boss_additive_mods[stat_name] += value
	else:
		super.apply_add_modifier(stat_name, value)

# Override apply_mult_modifier for boss stats
func apply_mult_modifier(stat_name: String, value: float):
	if boss_multiplicative_mods.has(stat_name):
		boss_multiplicative_mods[stat_name] *= value
	else:
		super.apply_mult_modifier(stat_name, value)

# Override reset_modifiers to include boss modifiers
func reset_modifiers():
	super.reset_modifiers()
	
	for key in boss_additive_mods.keys():
		boss_additive_mods[key] = 0
	for key in boss_multiplicative_mods.keys():
		boss_multiplicative_mods[key] = 1.0
	
