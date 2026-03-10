class_name PsycheManagerSettings
extends Resource

@export var serum_drop_rate: float;
@export var serum_start_level: float;

@export var normal_fog_density: float;
@export var serum_fog_density: float;

@export var serum_take_amount: float;

@export var serum_overdose_level: float;
@export var serum_critical_level: float;

@export var serum_to_normal_fog_speed: float;

@export var serum_invisibility_time: float;

@export_group("Fog Fade On Serum")
@export var fog_fade_drop_rate: float;
@export var fog_fade_start_level: float;
@export var fog_fade_addiction_addition: float;

@export_group("Craving")
@export var min_craving_timer: float;
@export var max_craving_timer: float;
@export var craving_duration: float;
@export var craving_player_force: float;
@export var craving_serum_take_radius: float;
@export var craving_serum_fov: float;

@export_group("Overtake")
@export var min_overtake_timer: float;
@export var max_overtake_timer: float;
@export var overtake_duration: float;
@export var overtake_player_force: float;

@export_group("Mutation Spawning")
@export var min_mutation_spawn_timer: float;
@export var max_mutation_spawn_timer: float;
@export var max_mutation_spawn_range: float;
@export var min_mutation_spawn_range: float;

@export_group("Saturation")
@export var serum_to_normal_saturation_speed: float;
@export var normal_saturation: float;
@export var overdose_saturation: float;
@export var critical_saturation: float;

@export_group("Vignette")
@export var serum_to_normal_vignette_speed: float;

@export_subgroup("Default Take Vignette")
@export var serum_vignette_intensity: float;
@export var serum_vignette_color: Color;
@export var serum_vignette_radius: float;

@export_subgroup("Overdose Take Vignette")
@export var serum_overdose_vignette_intensity: float;
# @export var serum_to_normal_overdose_vignette_speed: float;
@export var serum_overdose_vignette_color: Color;
@export var serum_overdose_vignette_radius: float;

@export_subgroup("Critical Take Vignette")
@export var serum_critical_vignette_intensity: float;
# @export var serum_to_overdose_critical_vignette_speed: float;
@export var serum_critical_vignette_color: Color;
@export var serum_critical_vignette_radius: float;
