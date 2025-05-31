extends Resource
class_name EnemyResource

@export var scene: PackedScene  # This was missing!
@export var max_health: int     # Renamed from hp to match enemy_base.gd
@export var speed: float
@export var attack_range: float
@export var attack_damage: float
@export var attack_cooldown: float
