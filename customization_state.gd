extends Node

const SAVE_PATH: String = "user://customization.json"
const SAVE_VERSION: int = 9

const DEFAULT_MARBLE_ID: String = "pearl_drift"
const DEFAULT_TRAIL_ID: String = "comet"
const DEFAULT_FIELD_ID: String = "glass_garden"
const DEFAULT_BANNER_ID: String = "crystal"
const DEFAULT_PLAYER_NAME: String = ""
const DEFAULT_SHOOT_SENSITIVITY: float = 1.0
const MIN_SHOOT_SENSITIVITY: float = 0.5
const MAX_SHOOT_SENSITIVITY: float = 1.5
const DEFAULT_AIM_INVERTED: bool = false
const STANDARD_MARBLE_S_COIN_COST: int = 100
const SPECIAL_MARBLE_GOLD_COST: int = 100
const SHOOTING_MECHANIC_DRAG: String = "drag"
const SHOOTING_MECHANIC_SPLIT: String = "split"
const SHOOTING_MECHANIC_PRESS: String = "press"
const DEFAULT_SHOOTING_MECHANIC: String = SHOOTING_MECHANIC_DRAG
const DEFAULT_UNLOCKED_MARBLE_IDS := [
	"pearl_drift"
]
const DEFAULT_UNLOCKED_FIELD_IDS := [
	"glass_garden"
]
const DEFAULT_UNLOCKED_BANNER_IDS := [
	"crystal"
]
const HIDDEN_MARBLE_IDS := []
const PREMIUM_IMPORTED_MARBLE_IDS := [
	"environment_sphere",
	"roblox_magic_sphere",
	"poke_ball",
	"rocket_league_ball",
	"cannonbolt_ball",
	"little_robot_ball",
	"pool_ball",
	"rainbow_galaxy_ball",
	"anime_red_black_ball",
	"marble_ball_3_import"
]

var selected_marble_id: String = DEFAULT_MARBLE_ID
var selected_trail_id: String = DEFAULT_TRAIL_ID
var selected_field_id: String = DEFAULT_FIELD_ID
var selected_banner_id: String = DEFAULT_BANNER_ID
var player_name: String = DEFAULT_PLAYER_NAME
var player_age: int = 0
var player_login_id: String = ""
var player_login_created_at: int = 0
var player_auth_provider: String = "guest"
var player_auth_email: String = ""
var player_auth_picture: String = ""
var player_auth_token: String = ""
var shoot_sensitivity: float = DEFAULT_SHOOT_SENSITIVITY
var aim_inverted: bool = DEFAULT_AIM_INVERTED
var shooting_mechanic: String = DEFAULT_SHOOTING_MECHANIC
var shooting_mechanic_prompt_seen: bool = false
var online_server_url: String = ""
var leaderboard_wins: Dictionary = {}
var leaderboard_names: Dictionary = {}
var unlocked_marble_ids: PackedStringArray = DEFAULT_UNLOCKED_MARBLE_IDS.duplicate()
var unlocked_field_ids: PackedStringArray = DEFAULT_UNLOCKED_FIELD_IDS.duplicate()
var unlocked_banner_ids: PackedStringArray = DEFAULT_UNLOCKED_BANNER_IDS.duplicate()

var marble_presets: Dictionary = {
	"pearl_drift": {
		"name": "Pearl Drift",
		"description": "Soft pearl marble with a pale sky tint.",
		"type": "stripe",
		"colors": [Color(0.94, 0.97, 1.0, 1.0), Color(0.78, 0.86, 0.98, 1.0), Color(0.70, 0.78, 0.92, 1.0)],
		"palette": {
			"marble_type": "stripe",
			"pattern_name": "default",
			"marble_scene_path": "res://marbles/marble_default_pearl.tscn",
			"shell_is_solid": true,
			"shell_base_color": Color(0.86, 0.9, 0.98, 0.96),
			"shell_swirl_orange": Color(0.94, 0.97, 1.0, 1.0),
			"shell_swirl_green": Color(0.78, 0.86, 0.98, 1.0),
			"shell_swirl_blue": Color(0.70, 0.78, 0.92, 1.0),
			"shell_roughness": 0.08
		}
	},
	"obsidian_drop": {
		"name": "Obsidian Drop",
		"description": "Dark neutral marble with a cool graphite sheen.",
		"type": "stripe",
		"colors": [Color(0.18, 0.22, 0.28, 1.0), Color(0.10, 0.12, 0.18, 1.0), Color(0.06, 0.09, 0.14, 1.0)],
		"palette": {
			"marble_type": "stripe",
			"pattern_name": "default",
			"marble_scene_path": "res://marbles/marble_default_obsidian.tscn",
			"shell_is_solid": true,
			"shell_base_color": Color(0.12, 0.14, 0.18, 0.96),
			"shell_swirl_orange": Color(0.18, 0.22, 0.28, 1.0),
			"shell_swirl_green": Color(0.10, 0.12, 0.18, 1.0),
			"shell_swirl_blue": Color(0.06, 0.09, 0.14, 1.0),
			"shell_roughness": 0.1
		}
	},
	"emerald_ribbon": {
		"name": "Emerald Ribbon",
		"description": "Fresh mint body with bright emerald bands.",
		"type": "stripe",
		"pattern": "stripe",
		"colors": [Color(0.12, 0.72, 0.34, 1.0), Color(0.90, 0.98, 0.94, 1.0), Color(0.08, 0.46, 0.22, 1.0)],
		"palette": {
			"marble_type": "stripe",
			"pattern_name": "stripe",
			"marble_scene_path": "res://marbles/marble_ribbon_emerald.tscn",
			"shell_is_solid": true,
			"shell_base_color": Color(0.90, 0.98, 0.94, 0.96),
			"shell_swirl_orange": Color(0.12, 0.72, 0.34, 1.0),
			"shell_swirl_green": Color(0.90, 0.98, 0.94, 1.0),
			"shell_swirl_blue": Color(0.08, 0.46, 0.22, 1.0),
			"shell_roughness": 0.08
		}
	},
	"cobalt_ribbon": {
		"name": "Cobalt Ribbon",
		"description": "Icy white shell cut with vivid cobalt bands.",
		"type": "stripe",
		"pattern": "stripe",
		"colors": [Color(0.14, 0.34, 0.94, 1.0), Color(0.92, 0.96, 1.0, 1.0), Color(0.06, 0.18, 0.62, 1.0)],
		"palette": {
			"marble_type": "stripe",
			"pattern_name": "stripe",
			"marble_scene_path": "res://marbles/marble_ribbon_cobalt.tscn",
			"shell_is_solid": true,
			"shell_base_color": Color(0.92, 0.96, 1.0, 0.96),
			"shell_swirl_orange": Color(0.14, 0.34, 0.94, 1.0),
			"shell_swirl_green": Color(0.92, 0.96, 1.0, 1.0),
			"shell_swirl_blue": Color(0.06, 0.18, 0.62, 1.0),
			"shell_roughness": 0.08
		}
	},
	"gold_ribbon": {
		"name": "Gold Ribbon",
		"description": "Warm ivory marble with bright gold ribbon lines.",
		"type": "stripe",
		"pattern": "stripe",
		"colors": [Color(0.98, 0.72, 0.14, 1.0), Color(0.98, 0.94, 0.82, 1.0), Color(0.74, 0.48, 0.10, 1.0)],
		"palette": {
			"marble_type": "stripe",
			"pattern_name": "stripe",
			"marble_scene_path": "res://marbles/marble_ribbon_gold.tscn",
			"shell_is_solid": true,
			"shell_base_color": Color(0.98, 0.94, 0.82, 0.96),
			"shell_swirl_orange": Color(0.98, 0.72, 0.14, 1.0),
			"shell_swirl_green": Color(0.98, 0.94, 0.82, 1.0),
			"shell_swirl_blue": Color(0.74, 0.48, 0.10, 1.0),
			"shell_roughness": 0.08
		}
	},
	"violet_ribbon": {
		"name": "Violet Ribbon",
		"description": "Lavender marble crossed with vivid violet ribbons.",
		"type": "default",
		"pattern": "stripe",
		"colors": [Color(0.62, 0.22, 0.92, 1.0), Color(0.96, 0.92, 1.0, 1.0), Color(0.34, 0.10, 0.60, 1.0)],
		"palette": {
			"marble_type": "default",
			"pattern_name": "stripe",
			"marble_scene_path": "res://marbles/marble_ribbon_violet.tscn",
			"shell_is_solid": true,
			"shell_base_color": Color(0.96, 0.92, 1.0, 0.96),
			"shell_swirl_orange": Color(0.62, 0.22, 0.92, 1.0),
			"shell_swirl_green": Color(0.96, 0.92, 1.0, 1.0),
			"shell_swirl_blue": Color(0.34, 0.10, 0.60, 1.0),
			"shell_roughness": 0.08
		}
	},
	"aqua_ribbon": {
		"name": "Aqua Ribbon",
		"description": "Bright aqua ribbons looping over a frosted shell.",
		"type": "default",
		"pattern": "stripe",
		"colors": [Color(0.10, 0.84, 0.92, 1.0), Color(0.90, 0.98, 1.0, 1.0), Color(0.06, 0.52, 0.58, 1.0)],
		"palette": {
			"marble_type": "default",
			"pattern_name": "stripe",
			"marble_scene_path": "res://marbles/marble_ribbon_aqua.tscn",
			"shell_is_solid": true,
			"shell_base_color": Color(0.90, 0.98, 1.0, 0.96),
			"shell_swirl_orange": Color(0.10, 0.84, 0.92, 1.0),
			"shell_swirl_green": Color(0.90, 0.98, 1.0, 1.0),
			"shell_swirl_blue": Color(0.06, 0.52, 0.58, 1.0),
			"shell_roughness": 0.08
		}
	},
	"orange_flame": {
		"name": "Orange Flame",
		"description": "Classic orange fire marble with a bright hot aura.",
		"type": "flame",
		"colors": [Color(1.0, 0.74, 0.12, 1.0), Color(1.0, 0.20, 0.02, 1.0), Color(0.22, 0.12, 0.06, 1.0)],
		"effects": {
			"emission_enabled": false,
			"emission_color": Color(1.0, 0.54, 0.08, 1.0),
			"emission_energy": 0.0,
			"flicker": false,
			"flicker_speed": 0.0,
			"flicker_amount": 0.0
		},
		"palette": {
			"marble_type": "flame",
			"pattern_name": "flame",
			"marble_scene_path": "res://marbles/marble_flame_orange.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.22, 0.12, 0.06, 0.96),
			"shell_swirl_orange": Color(1.0, 0.74, 0.12, 1.0),
			"shell_swirl_green": Color(1.0, 0.20, 0.02, 1.0),
			"shell_swirl_blue": Color(0.22, 0.12, 0.06, 1.0),
			"emission_enabled": false,
			"emission_color": Color(1.0, 0.54, 0.08, 1.0),
			"emission_energy": 0.0
		}
	},
	"blue_flame": {
		"name": "Blue Flame",
		"description": "Electric blue fire marble with a frosty outer burn.",
		"type": "flame",
		"colors": [Color(0.70, 0.96, 1.0, 1.0), Color(0.08, 0.36, 1.0, 1.0), Color(0.06, 0.10, 0.22, 1.0)],
		"effects": {
			"emission_enabled": false,
			"emission_color": Color(0.28, 0.68, 1.0, 1.0),
			"emission_energy": 0.0,
			"flicker": false,
			"flicker_speed": 0.0,
			"flicker_amount": 0.0
		},
		"palette": {
			"marble_type": "flame",
			"pattern_name": "flame",
			"marble_scene_path": "res://marbles/marble_flame_blue.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.06, 0.10, 0.22, 0.96),
			"shell_swirl_orange": Color(0.70, 0.96, 1.0, 1.0),
			"shell_swirl_green": Color(0.08, 0.36, 1.0, 1.0),
			"shell_swirl_blue": Color(0.06, 0.10, 0.22, 1.0),
			"emission_enabled": false,
			"emission_color": Color(0.28, 0.68, 1.0, 1.0),
			"emission_energy": 0.0
		}
	},
	"green_flame": {
		"name": "Green Flame",
		"description": "Acid green fire marble with a bright toxic-looking aura.",
		"type": "flame",
		"colors": [Color(0.82, 1.0, 0.40, 1.0), Color(0.14, 0.88, 0.28, 1.0), Color(0.06, 0.16, 0.08, 1.0)],
		"effects": {
			"emission_enabled": false,
			"emission_color": Color(0.42, 1.0, 0.34, 1.0),
			"emission_energy": 0.0,
			"flicker": false,
			"flicker_speed": 0.0,
			"flicker_amount": 0.0
		},
		"palette": {
			"marble_type": "flame",
			"pattern_name": "flame",
			"marble_scene_path": "res://marbles/marble_flame_green.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.06, 0.16, 0.08, 0.96),
			"shell_swirl_orange": Color(0.82, 1.0, 0.40, 1.0),
			"shell_swirl_green": Color(0.14, 0.88, 0.28, 1.0),
			"shell_swirl_blue": Color(0.06, 0.16, 0.08, 1.0),
			"emission_enabled": false,
			"emission_color": Color(0.42, 1.0, 0.34, 1.0),
			"emission_energy": 0.0
		}
	},
	"violet_flame": {
		"name": "Violet Flame",
		"description": "Arcane violet fire marble with a neon purple aura.",
		"type": "flame",
		"colors": [Color(1.0, 0.76, 1.0, 1.0), Color(0.58, 0.16, 1.0, 1.0), Color(0.12, 0.07, 0.20, 1.0)],
		"effects": {
			"emission_enabled": false,
			"emission_color": Color(0.76, 0.30, 1.0, 1.0),
			"emission_energy": 0.0,
			"flicker": false,
			"flicker_speed": 0.0,
			"flicker_amount": 0.0
		},
		"palette": {
			"marble_type": "flame",
			"pattern_name": "flame",
			"marble_scene_path": "res://marbles/marble_flame_violet.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.12, 0.07, 0.20, 0.96),
			"shell_swirl_orange": Color(1.0, 0.76, 1.0, 1.0),
			"shell_swirl_green": Color(0.58, 0.16, 1.0, 1.0),
			"shell_swirl_blue": Color(0.12, 0.07, 0.20, 1.0),
			"emission_enabled": false,
			"emission_color": Color(0.76, 0.30, 1.0, 1.0),
			"emission_energy": 0.0
		}
	},
	"environment_sphere": {
		"name": "Magic World Marble",
		"description": "Magic world marble.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(0.50, 0.84, 1.0, 1.0), Color(0.88, 0.96, 1.0, 1.0), Color(0.18, 0.26, 0.44, 1.0)],
		"effects": {
			"emission_enabled": false,
			"emission_color": Color(0.50, 0.84, 1.0, 1.0),
			"emission_energy": 0.0
		},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/environment_sphere_model.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.18, 0.26, 0.44, 0.96),
			"shell_swirl_orange": Color(0.50, 0.84, 1.0, 1.0),
			"shell_swirl_green": Color(0.88, 0.96, 1.0, 1.0),
			"shell_swirl_blue": Color(0.18, 0.26, 0.44, 1.0),
			"emission_enabled": false,
			"emission_color": Color(0.50, 0.84, 1.0, 1.0),
			"emission_energy": 0.0
		}
	},
	"roblox_magic_sphere": {
		"name": "Aura Marble",
		"description": "Aura marble.",
		"type": "premium",
		"pattern": "aura",
		"colors": [Color(0.58, 0.42, 1.0, 1.0), Color(0.86, 0.96, 1.0, 1.0), Color(0.16, 0.12, 0.38, 1.0)],
		"effects": {
			"emission_enabled": false,
			"emission_color": Color(0.58, 0.42, 1.0, 1.0),
			"emission_energy": 0.0
		},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "aura",
			"marble_scene_path": "res://marbles/roblox_magic_sphere_model.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.16, 0.12, 0.38, 0.96),
			"shell_swirl_orange": Color(0.58, 0.42, 1.0, 1.0),
			"shell_swirl_green": Color(0.86, 0.96, 1.0, 1.0),
			"shell_swirl_blue": Color(0.16, 0.12, 0.38, 1.0),
			"emission_enabled": false,
			"emission_color": Color(0.58, 0.42, 1.0, 1.0),
			"emission_energy": 0.0
		}
	},
	"poke_ball": {
		"name": "Poki Ball Marble",
		"description": "Poki ball marble.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(0.96, 0.22, 0.20, 1.0), Color(0.98, 0.98, 0.98, 1.0), Color(0.18, 0.18, 0.20, 1.0)],
		"effects": {
			"emission_enabled": false,
			"emission_color": Color(1.0, 0.86, 0.74, 1.0),
			"emission_energy": 0.0
		},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/poke_ball_model.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.98, 0.98, 0.98, 0.94),
			"shell_swirl_orange": Color(0.96, 0.22, 0.20, 1.0),
			"shell_swirl_green": Color(0.98, 0.98, 0.98, 1.0),
			"shell_swirl_blue": Color(0.18, 0.18, 0.20, 1.0),
			"emission_enabled": false,
			"emission_color": Color(1.0, 0.86, 0.74, 1.0),
			"emission_energy": 0.0
		}
	},
	"rocket_league_ball": {
		"name": "Rocket Ball Marble",
		"description": "Rocket ball marble.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(0.86, 0.86, 0.86, 1.0), Color(0.22, 0.22, 0.22, 1.0), Color(0.06, 0.06, 0.06, 1.0)],
		"effects": {"emission_enabled": false, "emission_color": Color(1, 1, 1, 1), "emission_energy": 0.0},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/rocket_league_ball_model.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.86, 0.86, 0.86, 0.96),
			"shell_swirl_orange": Color(0.86, 0.86, 0.86, 1.0),
			"shell_swirl_green": Color(0.22, 0.22, 0.22, 1.0),
			"shell_swirl_blue": Color(0.06, 0.06, 0.06, 1.0),
			"emission_enabled": false,
			"emission_color": Color(1, 1, 1, 1),
			"emission_energy": 0.0
		}
	},
	"cannonbolt_ball": {
		"name": "Cannonbolt Marble",
		"description": "Cannonbolt marble.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(0.96, 0.96, 0.84, 1.0), Color(0.42, 0.26, 0.16, 1.0), Color(0.12, 0.10, 0.08, 1.0)],
		"effects": {"emission_enabled": false, "emission_color": Color(1, 1, 1, 1), "emission_energy": 0.0},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/cannonbolt_ball_model.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.96, 0.96, 0.84, 0.96),
			"shell_swirl_orange": Color(0.96, 0.96, 0.84, 1.0),
			"shell_swirl_green": Color(0.42, 0.26, 0.16, 1.0),
			"shell_swirl_blue": Color(0.12, 0.10, 0.08, 1.0),
			"emission_enabled": false,
			"emission_color": Color(1, 1, 1, 1),
			"emission_energy": 0.0
		}
	},
	"little_robot_ball": {
		"name": "Robot Marble",
		"description": "Robot marble.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(0.86, 0.9, 0.94, 1.0), Color(0.42, 0.52, 0.64, 1.0), Color(0.12, 0.14, 0.18, 1.0)],
		"effects": {"emission_enabled": false, "emission_color": Color(1, 1, 1, 1), "emission_energy": 0.0},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/little_robot_ball_model.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.86, 0.9, 0.94, 0.96),
			"shell_swirl_orange": Color(0.86, 0.9, 0.94, 1.0),
			"shell_swirl_green": Color(0.42, 0.52, 0.64, 1.0),
			"shell_swirl_blue": Color(0.12, 0.14, 0.18, 1.0),
			"emission_enabled": false,
			"emission_color": Color(1, 1, 1, 1),
			"emission_energy": 0.0
		}
	},
	"pool_ball": {
		"name": "8 Ball Marble",
		"description": "8 ball marble.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(0.98, 0.94, 0.82, 1.0), Color(0.18, 0.18, 0.22, 1.0), Color(0.04, 0.04, 0.06, 1.0)],
		"effects": {"emission_enabled": false, "emission_color": Color(1, 1, 1, 1), "emission_energy": 0.0},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/pool_ball_model.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.98, 0.94, 0.82, 0.96),
			"shell_swirl_orange": Color(0.98, 0.94, 0.82, 1.0),
			"shell_swirl_green": Color(0.18, 0.18, 0.22, 1.0),
			"shell_swirl_blue": Color(0.04, 0.04, 0.06, 1.0),
			"emission_enabled": false,
			"emission_color": Color(1, 1, 1, 1),
			"emission_energy": 0.0
		}
	},
	"rainbow_galaxy_ball": {
		"name": "Aurora Marble",
		"description": "Aurora marble.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(0.94, 0.86, 1.0, 1.0), Color(0.36, 0.62, 1.0, 1.0), Color(0.14, 0.08, 0.24, 1.0)],
		"effects": {"emission_enabled": false, "emission_color": Color(1, 1, 1, 1), "emission_energy": 0.0},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/rainbow_galaxy_ball_model.tscn",
			"finish": "standard",
			"shell_is_solid": true,
			"shell_base_color": Color(0.94, 0.86, 1.0, 0.96),
			"shell_swirl_orange": Color(0.94, 0.86, 1.0, 1.0),
			"shell_swirl_green": Color(0.36, 0.62, 1.0, 1.0),
			"shell_swirl_blue": Color(0.14, 0.08, 0.24, 1.0),
			"emission_enabled": false,
			"emission_color": Color(1, 1, 1, 1),
			"emission_energy": 0.0
		}
	},
	"anime_red_black_ball": {
		"name": "Anime VFX Red Black",
		"description": "Red and black anime energy marble.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(1.0, 0.08, 0.04, 1.0), Color(0.08, 0.02, 0.02, 1.0), Color(0.42, 0.0, 0.0, 1.0)],
		"effects": {"emission_enabled": true, "emission_color": Color(1, 0.08, 0.04, 1), "emission_energy": 0.55},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/new_anime_vfx_red_black_ball_model.tscn",
			"finish": "standard",
			"preserve_imported_look": true,
			"shell_is_solid": true,
			"shell_base_color": Color(0.08, 0.02, 0.02, 0.96),
			"shell_swirl_orange": Color(1.0, 0.08, 0.04, 1.0),
			"shell_swirl_green": Color(0.42, 0.0, 0.0, 1.0),
			"shell_swirl_blue": Color(0.0, 0.0, 0.0, 1.0),
			"emission_enabled": true,
			"emission_color": Color(1, 0.08, 0.04, 1),
			"emission_energy": 0.55
		}
	},
	"marble_ball_3_import": {
		"name": "Marble Ball III",
		"description": "Imported marble ball variant.",
		"type": "premium",
		"pattern": "glass",
		"colors": [Color(0.92, 0.94, 1.0, 1.0), Color(0.34, 0.44, 0.72, 1.0), Color(0.08, 0.10, 0.18, 1.0)],
		"effects": {"emission_enabled": false, "emission_color": Color(1, 1, 1, 1), "emission_energy": 0.0},
		"palette": {
			"marble_type": "premium",
			"pattern_name": "glass",
			"marble_scene_path": "res://marbles/marble_ball_3_import_model.tscn",
			"finish": "standard",
			"preserve_imported_look": true,
			"shell_is_solid": true,
			"shell_base_color": Color(0.92, 0.94, 1.0, 0.96),
			"shell_swirl_orange": Color(0.92, 0.94, 1.0, 1.0),
			"shell_swirl_green": Color(0.34, 0.44, 0.72, 1.0),
			"shell_swirl_blue": Color(0.08, 0.10, 0.18, 1.0),
			"emission_enabled": false,
			"emission_color": Color(1, 1, 1, 1),
			"emission_energy": 0.0
		}
	},
}

var trail_presets: Dictionary = {
	"none": {
		"name": "No Trail",
		"description": "No trail effect.",
		"enabled": false
	},
	"comet": {
		"name": "Comet",
		"description": "Bright cyan marble glow trail.",
		"enabled": true,
		"color": Color(0.42, 0.92, 1.0, 0.34),
		"emission": Color(0.18, 0.8, 1.0, 1.0),
		"scale": 0.12,
		"lifetime": 0.42,
		"interval": 0.035
	},
	"particle_loop": {
		"name": "Particle Loop",
		"description": "Imported looping particle trail.",
		"enabled": true,
		"color": Color(0.5, 0.9, 1.0, 0.38),
		"secondary_color": Color(0.88, 0.96, 1.0, 0.26),
		"emission": Color(0.24, 0.74, 1.0, 1.0),
		"scale": 0.16,
		"lifetime": 0.42,
		"interval": 0.03,
		"shape": "spark",
		"scene_path": "res://looping_particle_trail_fbx_0.9mb.glb"
	},
	"ember": {
		"name": "Ember",
		"description": "Warm orange sparks trailing behind the marble.",
		"enabled": true,
		"color": Color(1.0, 0.58, 0.18, 0.34),
		"emission": Color(1.0, 0.34, 0.08, 1.0),
		"scale": 0.11,
		"lifetime": 0.34,
		"interval": 0.03
	},
	"mint": {
		"name": "Mint Mist",
		"description": "Soft green glassy trail.",
		"enabled": true,
		"color": Color(0.54, 1.0, 0.78, 0.28),
		"emission": Color(0.22, 0.86, 0.54, 1.0),
		"scale": 0.13,
		"lifetime": 0.4,
		"interval": 0.038
	},
	"violet": {
		"name": "Violet Arc",
		"description": "Electric purple neon trail.",
		"enabled": true,
		"color": Color(0.74, 0.56, 1.0, 0.3),
		"emission": Color(0.52, 0.28, 1.0, 1.0),
		"scale": 0.115,
		"lifetime": 0.36,
		"interval": 0.03
	},
	"gold": {
		"name": "Gold Dust",
		"description": "Short golden shimmer behind the marble.",
		"enabled": true,
		"color": Color(1.0, 0.88, 0.34, 0.28),
		"emission": Color(0.98, 0.74, 0.18, 1.0),
		"secondary_color": Color(1.0, 0.98, 0.72, 0.24),
		"scale": 0.105,
		"lifetime": 0.32,
		"interval": 0.028,
		"shape": "dust"
	},
	"kenya_pulse": {
		"name": "Kenya Pulse",
		"description": "Fast red, green, and white energy streaks.",
		"enabled": true,
		"color": Color(0.88, 0.16, 0.18, 0.44),
		"secondary_color": Color(0.14, 0.62, 0.22, 0.32),
		"emission": Color(0.96, 0.96, 0.96, 1.0),
		"scale": 0.18,
		"lifetime": 0.5,
		"interval": 0.018,
		"shape": "ribbon"
	},
	"aurora_ribbon": {
		"name": "Aurora Ribbon",
		"description": "Soft northern-light trail with cyan and violet layers.",
		"enabled": true,
		"color": Color(0.42, 1.0, 0.9, 0.46),
		"secondary_color": Color(0.76, 0.5, 1.0, 0.42),
		"emission": Color(0.56, 0.98, 1.0, 1.0),
		"scale": 0.2,
		"lifetime": 0.55,
		"interval": 0.022,
		"shape": "ribbon"
	},
	"safari_dust": {
		"name": "Safari Dust",
		"description": "Warm sand trail with a dry glowing haze.",
		"enabled": true,
		"color": Color(0.88, 0.62, 0.24, 0.34),
		"secondary_color": Color(0.44, 0.24, 0.12, 0.2),
		"emission": Color(0.96, 0.74, 0.28, 1.0),
		"scale": 0.17,
		"lifetime": 0.46,
		"interval": 0.024,
		"shape": "dust"
	},
	"lagoon_comet": {
		"name": "Lagoon Comet",
		"description": "Dense tropical blue-green comet tail.",
		"enabled": true,
		"color": Color(0.18, 0.84, 0.98, 0.42),
		"secondary_color": Color(0.18, 0.98, 0.64, 0.28),
		"emission": Color(0.08, 0.72, 1.0, 1.0),
		"scale": 0.19,
		"lifetime": 0.48,
		"interval": 0.02,
		"shape": "comet"
	},
	"violet_static": {
		"name": "Violet Static",
		"description": "Electric purple trail with sharp bright flickers.",
		"enabled": true,
		"color": Color(0.72, 0.42, 1.0, 0.34),
		"secondary_color": Color(0.96, 0.76, 1.0, 0.2),
		"emission": Color(0.56, 0.22, 1.0, 1.0),
		"scale": 0.15,
		"lifetime": 0.38,
		"interval": 0.018,
		"shape": "spark"
	}
}

var banner_presets: Dictionary = {
	"crystal": {
		"name": "Crystal Tag",
		"description": "Clean glass name tag with cyan trim.",
		"fill": Color(0.02, 0.07, 0.10, 0.58),
		"accent": Color(0.42, 0.92, 1.0, 1.0),
		"text": Color(0.96, 0.99, 1.0, 1.0),
		"outline": Color(0.0, 0.02, 0.06, 0.92),
		"shape": "banner",
		"style": "crystal",
		"cost": 0
	},
	"inferno": {
		"name": "Inferno Burner",
		"description": "Premium fire banner with hot orange glow.",
		"fill": Color(0.18, 0.035, 0.02, 0.72),
		"accent": Color(1.0, 0.42, 0.08, 1.0),
		"text": Color(1.0, 0.94, 0.78, 1.0),
		"outline": Color(0.18, 0.02, 0.0, 0.96),
		"shape": "burner",
		"style": "flame",
		"cost": 160
	},
	"royal_bubble": {
		"name": "Royal Bubble",
		"description": "Rounded purple-blue bubble for your name tag.",
		"fill": Color(0.12, 0.07, 0.26, 0.74),
		"accent": Color(0.82, 0.54, 1.0, 1.0),
		"text": Color(0.98, 0.94, 1.0, 1.0),
		"outline": Color(0.02, 0.0, 0.08, 0.96),
		"shape": "bubble",
		"style": "glow",
		"cost": 140
	},
	"gold_plate": {
		"name": "Gold Plate",
		"description": "Luxury gold nameplate with bold dark contrast.",
		"fill": Color(0.26, 0.17, 0.04, 0.78),
		"accent": Color(1.0, 0.78, 0.18, 1.0),
		"text": Color(1.0, 0.94, 0.72, 1.0),
		"outline": Color(0.10, 0.06, 0.0, 0.98),
		"shape": "plate",
		"style": "plate",
		"cost": 180
	},
	"lagoon_pop": {
		"name": "Lagoon Pop",
		"description": "Bright aqua-green custom bubble with a soft glow.",
		"fill": Color(0.02, 0.15, 0.16, 0.72),
		"accent": Color(0.18, 1.0, 0.72, 1.0),
		"text": Color(0.86, 1.0, 0.96, 1.0),
		"outline": Color(0.0, 0.08, 0.07, 0.96),
		"shape": "bubble",
		"style": "aqua_glow",
		"cost": 120
	},
	"cyber_diamond": {
		"name": "Cyber Diamond",
		"description": "Sharp black-cyan esports banner with a diamond badge.",
		"fill": Color(0.005, 0.012, 0.016, 0.94),
		"accent": Color(0.08, 0.78, 1.0, 1.0),
		"text": Color(0.9, 0.98, 1.0, 1.0),
		"outline": Color(0.0, 0.02, 0.04, 0.98),
		"shape": "plate",
		"style": "cyber_diamond",
		"cost": 220
	},
	"royal_scroll": {
		"name": "Royal Scroll",
		"description": "Elegant violet scroll banner with soft gold details.",
		"fill": Color(0.48, 0.34, 0.96, 0.92),
		"accent": Color(1.0, 0.74, 0.28, 1.0),
		"text": Color(1.0, 0.95, 0.78, 1.0),
		"outline": Color(0.20, 0.08, 0.34, 0.98),
		"shape": "bubble",
		"style": "royal_scroll",
		"cost": 240
	},
	"antique_scroll": {
		"name": "Antique Scroll",
		"description": "Classic parchment banner artwork with the white background removed.",
		"fill": Color(0.75, 0.62, 0.38, 0.92),
		"accent": Color(0.17, 0.13, 0.08, 1.0),
		"text": Color(0.18, 0.11, 0.05, 1.0),
		"outline": Color(0.92, 0.78, 0.48, 0.78),
		"shape": "plate",
		"style": "texture",
		"texture_path": "res://ui/banners/antique_scroll_banner.png",
		"texture_aspect": 3.1579,
		"text_area_ratio": 0.74,
		"text_font_scale": 0.76,
		"cost": 0
	},
	"royal_wings": {
		"name": "Royal Wings",
		"description": "Gold and purple winged banner artwork with the dark background removed.",
		"fill": Color(0.96, 0.68, 0.06, 0.94),
		"accent": Color(0.82, 0.12, 1.0, 1.0),
		"text": Color(0.34, 0.16, 0.02, 1.0),
		"outline": Color(1.0, 0.94, 0.66, 0.88),
		"shape": "plate",
		"style": "texture",
		"texture_path": "res://ui/banners/royal_wings_banner.png",
		"texture_aspect": 2.3,
		"text_area_ratio": 0.50,
		"text_font_scale": 0.62,
		"cost": 0
	},
	"red_flame_frame": {
		"name": "Red Flame Frame",
		"description": "Red fantasy frame banner artwork with the dark background removed.",
		"fill": Color(0.72, 0.20, 0.16, 0.94),
		"accent": Color(1.0, 0.86, 0.46, 1.0),
		"text": Color(1.0, 0.92, 0.72, 1.0),
		"outline": Color(0.32, 0.05, 0.02, 0.92),
		"shape": "plate",
		"style": "texture",
		"texture_path": "res://ui/banners/red_flame_frame_banner.png",
		"texture_aspect": 2.8235,
		"text_area_ratio": 0.64,
		"text_font_scale": 0.72,
		"text_x_offset_3d": 0.08,
		"text_y_offset_3d": 0.0,
		"text_y_offset_2d": 0.0,
		"cost": 0
	},
	"koi_gold": {
		"name": "Koi Gold",
		"description": "Golden koi banner artwork with the black background removed.",
		"fill": Color(0.95, 0.66, 0.08, 0.94),
		"accent": Color(1.0, 0.36, 0.04, 1.0),
		"text": Color(0.30, 0.10, 0.01, 1.0),
		"outline": Color(1.0, 0.86, 0.30, 0.88),
		"shape": "plate",
		"style": "texture",
		"texture_path": "res://ui/banners/koi_gold_banner.png",
		"texture_aspect": 2.7692,
		"text_area_ratio": 0.50,
		"text_font_scale": 0.62,
		"cost": 0
	},
	"neon_stitch": {
		"name": "Neon Stitch",
		"description": "Red neon video banner frame with the dark background removed.",
		"fill": Color(0.34, 0.04, 0.08, 0.90),
		"accent": Color(1.0, 0.22, 0.28, 1.0),
		"text": Color(1.0, 0.88, 0.90, 1.0),
		"outline": Color(0.20, 0.0, 0.03, 0.95),
		"shape": "plate",
		"style": "texture",
		"texture_path": "res://ui/banners/neon_stitch_banner.png",
		"video_path": "res://ui/banners/neon_stitch_banner.ogv",
		"texture_aspect": 2.5,
		"text_area_ratio": 0.96,
		"text_font_scale": 0.72,
		"text_y_offset_2d": 12.0,
		"text_y_offset_3d": -0.065,
		"cost": 0
	},
	"bd_strip": {
		"name": "BD Strip",
		"description": "Silver and blue badge strip banner with the white background removed.",
		"fill": Color(0.12, 0.25, 0.35, 0.94),
		"accent": Color(0.78, 0.90, 1.0, 1.0),
		"text": Color(0.88, 0.96, 1.0, 1.0),
		"outline": Color(0.02, 0.08, 0.13, 0.95),
		"shape": "plate",
		"style": "texture",
		"texture_path": "res://ui/banners/bd_strip_banner.png",
		"texture_aspect": 3.098,
		"text_area_ratio": 0.54,
		"text_font_scale": 0.74,
		"text_x_offset_2d": 58.0,
		"text_x_offset_3d": 0.16,
		"text_y_offset_3d": -0.015,
		"cost": 0
	},
	"red_shadow": {
		"name": "Red Shadow",
		"description": "Dark red jagged banner artwork with the checker background removed.",
		"fill": Color(0.10, 0.0, 0.0, 0.94),
		"accent": Color(1.0, 0.05, 0.08, 1.0),
		"text": Color(1.0, 0.86, 0.90, 1.0),
		"outline": Color(0.08, 0.0, 0.0, 0.96),
		"shape": "plate",
		"style": "texture",
		"texture_path": "res://ui/banners/red_shadow_banner.png",
		"texture_aspect": 1.6782,
		"text_area_ratio": 0.66,
		"text_font_scale": 0.72,
		"text_y_offset_2d": -10.0,
		"text_y_offset_3d": 0.035,
		"cost": 0
	},
	"black_gold_pill": {
		"name": "Black Gold Pill",
		"description": "Clean black and gold rounded banner artwork with the dark background removed.",
		"fill": Color(0.09, 0.09, 0.08, 0.94),
		"accent": Color(1.0, 0.78, 0.24, 1.0),
		"text": Color(1.0, 0.90, 0.56, 1.0),
		"outline": Color(0.0, 0.0, 0.0, 0.9),
		"shape": "plate",
		"style": "texture",
		"texture_path": "res://ui/banners/black_gold_pill_banner.png",
		"texture_aspect": 4.8438,
		"text_area_ratio": 0.80,
		"text_font_scale": 0.78,
		"cost": 0
	}
}

var field_presets: Dictionary = {
	"glass_garden": {
		"name": "Glass Garden",
		"description": "Clean emerald glass fairway with soft cyan water and a bright premium daytime sky.",
		"layout_id": "classic",
		"showroom_scene_path": "res://showroom_fields/field_preview_glass_garden.tscn",
		"colors": [Color(0.40, 0.76, 0.42, 1.0), Color(0.58, 0.90, 0.98, 1.0), Color(0.84, 0.95, 1.0, 1.0)],
		"theme": {
			"fairway_base": Color(0.34, 0.61, 0.31, 1.0),
			"fairway_light": Color(0.51, 0.72, 0.43, 1.0),
			"fairway_dark": Color(0.24, 0.46, 0.25, 1.0),
			"dry_patch": Color(0.47, 0.58, 0.39, 1.0),
			"stripe_scale": 13.5,
			"noise_scale": 18.0,
			"sky_top": Color(0.31, 0.56, 0.84, 1.0),
			"sky_horizon": Color(0.80, 0.90, 0.97, 1.0),
			"ground_bottom": Color(0.18, 0.28, 0.21, 1.0),
			"ground_horizon": Color(0.40, 0.52, 0.42, 1.0),
			"ambient_color": Color(0.73, 0.82, 0.89, 1.0),
			"ambient_energy": 0.78,
			"fog_color": Color(0.71, 0.82, 0.89, 1.0),
			"fog_energy": 0.42,
			"fog_density": 0.0052,
			"sun_color": Color(1.0, 0.96, 0.90, 1.0),
			"sun_energy": 1.35,
			"lake_shallow": Color(0.08, 0.34, 0.42, 1.0),
			"lake_deep": Color(0.03, 0.12, 0.18, 1.0),
			"lake_foam": Color(0.78, 0.94, 1.0, 1.0),
			"showroom_bg": Color(0.64, 0.84, 1.0, 1.0),
			"showroom_ambient": Color(0.82, 0.92, 1.0, 1.0),
			"showroom_light": Color(0.72, 0.9, 1.0, 1.0),
			"showroom_rim": Color(0.86, 0.96, 1.0, 1.0),
			"showroom_platform": Color(0.05, 0.12, 0.16, 1.0)
		}
	}
}


func _ready() -> void:
	load_state()


func get_marble_ids() -> PackedStringArray:
	var visible_ids: PackedStringArray = PackedStringArray()
	for marble_id_variant in marble_presets.keys():
		var marble_id: String = str(marble_id_variant)
		if not _is_marble_hidden(marble_id):
			visible_ids.append(marble_id)
	return visible_ids


func get_trail_ids() -> PackedStringArray:
	return PackedStringArray(trail_presets.keys())


func get_banner_ids() -> PackedStringArray:
	return PackedStringArray(banner_presets.keys())


func get_field_ids() -> PackedStringArray:
	return PackedStringArray(field_presets.keys())


func get_marble_preset(id: String) -> Dictionary:
	var preset: Dictionary = marble_presets.get(id, marble_presets[DEFAULT_MARBLE_ID])
	return _normalize_marble_preset(id, preset)


func get_trail_preset(id: String) -> Dictionary:
	var preset: Dictionary = trail_presets.get(id, trail_presets[DEFAULT_TRAIL_ID])
	var normalized: Dictionary = preset.duplicate(true)
	normalized["id"] = id if trail_presets.has(id) else DEFAULT_TRAIL_ID
	return normalized


func get_banner_preset(id: String) -> Dictionary:
	var preset: Dictionary = banner_presets.get(id, banner_presets[DEFAULT_BANNER_ID]).duplicate(true)
	preset["id"] = id if banner_presets.has(id) else DEFAULT_BANNER_ID
	return preset


func get_selected_marble_preset() -> Dictionary:
	return get_marble_preset(selected_marble_id)


func get_selected_palette() -> Dictionary:
	var preset: Dictionary = get_selected_marble_preset()
	var palette: Dictionary = preset.get("palette", {})
	return palette.duplicate(true)


func get_selected_marble_visual_data() -> Dictionary:
	return get_selected_marble_preset()


func get_selected_marble_type() -> String:
	var preset: Dictionary = get_selected_marble_preset()
	return str(preset.get("type", "default"))


func get_selected_trail_preset() -> Dictionary:
	return get_trail_preset(selected_trail_id)


func get_selected_banner_preset() -> Dictionary:
	return get_banner_preset(selected_banner_id)


func get_field_preset(id: String) -> Dictionary:
	var preset: Dictionary = field_presets.get(id, field_presets[DEFAULT_FIELD_ID]).duplicate(true)
	preset["id"] = id if field_presets.has(id) else DEFAULT_FIELD_ID
	return preset


func get_selected_field_preset() -> Dictionary:
	return get_field_preset(selected_field_id)


func _normalize_marble_preset(id: String, source: Dictionary) -> Dictionary:
	var preset: Dictionary = source.duplicate(true)
	var palette: Dictionary = _build_palette_for_preset(preset)
	var colors: Array = _get_palette_colors(palette)
	var effects: Dictionary = {
		"emission_enabled": bool(palette.get("emission_enabled", false)),
		"emission_color": palette.get("emission_color", colors[1]),
		"emission_energy": float(palette.get("emission_energy", 0.0)),
		"flicker": bool(palette.get("flicker_enabled", false)),
		"flicker_speed": float(palette.get("flicker_speed", 0.0)),
		"flicker_amount": float(palette.get("flicker_amount", 0.0))
	}
	preset["id"] = id
	preset["type"] = str(palette.get("marble_type", "default"))
	preset["pattern"] = str(palette.get("pattern_name", "default"))
	preset["colors"] = colors.duplicate(true)
	preset["effects"] = effects
	preset["palette"] = palette
	return preset


func _build_palette_for_preset(preset: Dictionary) -> Dictionary:
	var palette: Dictionary = preset.get("palette", {}).duplicate(true)
	var colors: Array = _extract_color_array(preset.get("colors", palette.get("colors", [])))
	if colors.is_empty():
		colors = [
			palette.get("shell_swirl_orange", palette.get("albedo_color", palette.get("shell_base_color", Color(0.94, 0.48, 0.17, 1.0)))),
			palette.get("shell_swirl_green", Color(0.22, 0.78, 0.34, 1.0)),
			palette.get("shell_swirl_blue", Color(0.07, 0.18, 0.86, 1.0)),
			palette.get("shell_swirl_shadow", Color(0.16, 0.12, 0.22, 1.0))
		]

	var marble_type: String = _normalize_marble_type(str(preset.get("type", palette.get("marble_type", ""))), palette, preset)
	var pattern_name: String = str(preset.get("pattern", palette.get("pattern_name", _infer_pattern_name(palette))))
	var effects: Dictionary = preset.get("effects", {})
	var fallback_base: Color = palette.get("shell_base_color", palette.get("albedo_color", colors[0]))
	var shell_base: Color = fallback_base
	if not bool(palette.get("shell_is_solid", marble_type not in ["premium", "flame"])):
		shell_base.a = minf(shell_base.a, 0.18)
	elif shell_base.a < 0.98:
		shell_base.a = 0.96
	shell_base.a = 1.0

	palette["marble_type"] = marble_type
	palette["pattern_name"] = pattern_name
	palette["colors"] = colors.duplicate(true)
	palette["shell_base_color"] = shell_base
	palette["albedo_color"] = palette.get("albedo_color", shell_base)
	palette["shell_swirl_orange"] = colors[0]
	palette["shell_swirl_green"] = colors[min(1, colors.size() - 1)]
	palette["shell_swirl_blue"] = colors[min(2, colors.size() - 1)]
	palette["shell_swirl_shadow"] = colors[min(3, colors.size() - 1)] if colors.size() > 3 else colors[0].darkened(0.55)
	palette["shell_roughness"] = maxf(float(palette.get("shell_roughness", palette.get("roughness", 0.62))), 0.62)
	palette["roughness"] = maxf(float(palette.get("roughness", palette["shell_roughness"])), 0.62)
	palette["shell_is_solid"] = true
	palette["finish"] = "standard"
	palette["emission_enabled"] = false
	palette["emission_color"] = Color(0.0, 0.0, 0.0, 1.0)
	palette["emission_energy"] = 0.0
	palette["flicker_enabled"] = false
	palette["flicker_speed"] = 0.0
	palette["flicker_amount"] = 0.0
	palette["colors"] = colors.duplicate(true)
	return palette


func _extract_color_array(value: Variant) -> Array:
	var colors: Array = []
	if typeof(value) != TYPE_ARRAY:
		return colors
	for entry in value:
		if entry is Color:
			colors.append(entry)
	while colors.size() < 3:
		colors.append(colors.back() if not colors.is_empty() else Color(0.58, 0.8, 1.0, 1.0))
	return colors


func _get_palette_colors(palette: Dictionary) -> Array:
	return _extract_color_array(palette.get("colors", []))


func _infer_marble_type(preset: Dictionary, palette: Dictionary) -> String:
	var finish: String = str(palette.get("finish", ""))
	if finish == "fire":
		return "flame"
	if finish in ["glow", "neon", "metal", "dark"] or bool(palette.get("emission_enabled", false)):
		return "premium"
	var explicit_pattern: String = str(preset.get("pattern", "")).to_lower()
	if explicit_pattern in ["swirl", "stripe", "gradient"]:
		return explicit_pattern
	return "default"


func _infer_pattern_name(palette: Dictionary) -> String:
	if palette.has("pattern_name"):
		return str(palette.get("pattern_name"))
	var pattern_mode: float = float(palette.get("pattern_mode", 0.0))
	if pattern_mode > 2.5:
		return "stripe"
	if pattern_mode > 1.5:
		return "gradient"
	if pattern_mode > 0.5:
		return "gradient"
	return "default"


func _default_finish_for_type(marble_type: String) -> String:
	match marble_type:
		_:
			return "standard"


func _normalize_marble_type(raw_type: String, palette: Dictionary, preset: Dictionary) -> String:
	match raw_type.to_lower():
		"default", "classic", "standard":
			if preset.has("pattern"):
				var explicit_pattern: String = str(preset.get("pattern", "")).to_lower()
				if explicit_pattern in ["swirl", "stripe", "gradient"]:
					return explicit_pattern
			return "default"
		"swirl":
			return "swirl"
		"stripe", "stripes":
			return "stripe"
		"gradient":
			return "gradient"
		"premium", "glow", "neon", "metal", "dark":
			return "premium"
		"flame", "fire":
			return "flame"
		_:
			return _infer_marble_type(preset, palette)


func get_player_name() -> String:
	return player_name


func get_player_age() -> int:
	return player_age


func has_player_name() -> bool:
	return player_name.strip_edges() != ""


func get_player_login_id() -> String:
	if player_login_id.strip_edges() == "" and has_player_name():
		_ensure_player_login_id()
		save_state()
	return player_login_id


func has_player_login() -> bool:
	return has_player_name() and get_player_login_id().strip_edges() != ""


func get_player_login_summary() -> Dictionary:
	return {
		"id": get_player_login_id(),
		"name": get_player_name(),
		"provider": get_player_auth_provider(),
		"email": player_auth_email,
		"created_at": player_login_created_at
	}


func get_player_auth_provider() -> String:
	return player_auth_provider if player_auth_provider.strip_edges() != "" else "guest"


func get_player_auth_token() -> String:
	return player_auth_token


func is_google_player_login() -> bool:
	return get_player_auth_provider() == "google" and player_login_id.begins_with("google:")


func set_google_player_profile(profile: Dictionary) -> void:
	var google_login_id: String = str(profile.get("login_id", "")).strip_edges()
	if google_login_id == "":
		return
	player_login_id = google_login_id.left(40)
	player_auth_provider = "google"
	player_auth_email = str(profile.get("email", "")).strip_edges().left(120)
	player_auth_picture = str(profile.get("picture", "")).strip_edges().left(240)
	player_auth_token = str(profile.get("auth_token", "")).strip_edges().left(128)
	var profile_name: String = str(profile.get("name", "")).strip_edges()
	if profile_name != "":
		player_name = profile_name.left(18)
	if player_login_created_at <= 0:
		player_login_created_at = int(Time.get_unix_time_from_system())
	var remote_age: int = int(profile.get("player_age", 0))
	if remote_age > 0 and player_age <= 0:
		player_age = clampi(remote_age, 1, 120)
	var progress_value: Variant = profile.get("progress", {})
	if typeof(progress_value) == TYPE_DICTIONARY:
		var progress: Dictionary = progress_value
		_apply_remote_progress(progress)
	save_state()


func _ensure_player_login_id() -> void:
	if player_login_id.strip_edges() != "":
		return
	player_login_id = _generate_player_login_id()
	if player_login_created_at <= 0:
		player_login_created_at = int(Time.get_unix_time_from_system())


func _generate_player_login_id() -> String:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var alphabet: String = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var code: String = ""
	for _index in range(6):
		code += alphabet.substr(rng.randi_range(0, alphabet.length() - 1), 1)
	return "BKE-%s" % code


func get_coin_balance() -> int:
	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager != null and currency_manager.has_method("get_coins"):
		return int(currency_manager.call("get_coins"))
	return 0


func get_gold_balance() -> int:
	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager != null and currency_manager.has_method("get_gold"):
		return int(currency_manager.call("get_gold"))
	return 0


func get_currency_balance(currency: String) -> int:
	match currency.to_lower():
		"gold":
			return get_gold_balance()
		_:
			return get_coin_balance()


func get_currency_display_name(currency: String) -> String:
	return "Gold" if currency.to_lower() == "gold" else "S coins"


func get_marble_unlock_cost(id: String) -> int:
	if not marble_presets.has(id) or _is_marble_hidden(id):
		return 0
	return 0


func get_marble_unlock_currency(id: String) -> String:
	return "coins"


func get_field_unlock_cost(id: String) -> int:
	return 0


func get_field_unlock_currency(id: String) -> String:
	return "coins"


func get_banner_unlock_cost(id: String) -> int:
	if id == DEFAULT_BANNER_ID:
		return 0
	if not banner_presets.has(id):
		return 0
	return int(banner_presets[id].get("cost", 120))


func get_banner_unlock_currency(id: String) -> String:
	return "coins"


func is_marble_unlocked(id: String) -> bool:
	if not marble_presets.has(id):
		return false
	if _is_marble_hidden(id):
		return false
	return true


func can_unlock_marble(id: String) -> bool:
	if not marble_presets.has(id):
		return false
	if _is_marble_hidden(id):
		return false
	if is_marble_unlocked(id):
		return true
	return get_currency_balance(get_marble_unlock_currency(id)) >= get_marble_unlock_cost(id)


func is_field_unlocked(id: String) -> bool:
	if not field_presets.has(id):
		return false
	if get_field_unlock_cost(id) <= 0:
		return true
	return unlocked_field_ids.has(id)


func can_unlock_field(id: String) -> bool:
	if not field_presets.has(id):
		return false
	if is_field_unlocked(id):
		return true
	return get_currency_balance(get_field_unlock_currency(id)) >= get_field_unlock_cost(id)


func is_banner_unlocked(id: String) -> bool:
	if not banner_presets.has(id):
		return false
	if get_banner_unlock_cost(id) <= 0:
		return true
	return unlocked_banner_ids.has(id)


func can_unlock_banner(id: String) -> bool:
	if not banner_presets.has(id):
		return false
	if is_banner_unlocked(id):
		return true
	return get_currency_balance(get_banner_unlock_currency(id)) >= get_banner_unlock_cost(id)


func unlock_marble(id: String) -> bool:
	if not marble_presets.has(id):
		return false
	if _is_marble_hidden(id):
		return false
	if is_marble_unlocked(id):
		return true

	var unlock_cost: int = get_marble_unlock_cost(id)
	var currency: String = get_marble_unlock_currency(id)
	if get_currency_balance(currency) < unlock_cost:
		return false

	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager == null:
		return false
	var spent: bool = false
	if currency == "gold" and currency_manager.has_method("spend_gold"):
		spent = bool(currency_manager.call("spend_gold", unlock_cost))
	elif currency_manager.has_method("spend_coins"):
		spent = bool(currency_manager.call("spend_coins", unlock_cost))
	if not spent:
		return false
	if not unlocked_marble_ids.has(id):
		unlocked_marble_ids.append(id)
	save_state()
	return true


func unlock_field(id: String) -> bool:
	if not field_presets.has(id):
		return false
	if is_field_unlocked(id):
		return true

	var unlock_cost: int = get_field_unlock_cost(id)
	var currency: String = get_field_unlock_currency(id)
	if get_currency_balance(currency) < unlock_cost:
		return false

	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager == null:
		return false
	var spent: bool = false
	if currency == "gold" and currency_manager.has_method("spend_gold"):
		spent = bool(currency_manager.call("spend_gold", unlock_cost))
	elif currency_manager.has_method("spend_coins"):
		spent = bool(currency_manager.call("spend_coins", unlock_cost))
	if not spent:
		return false
	if not unlocked_field_ids.has(id):
		unlocked_field_ids.append(id)
	save_state()
	return true


func unlock_banner(id: String) -> bool:
	if not banner_presets.has(id):
		return false
	if is_banner_unlocked(id):
		return true

	var unlock_cost: int = get_banner_unlock_cost(id)
	var currency: String = get_banner_unlock_currency(id)
	if get_currency_balance(currency) < unlock_cost:
		return false

	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager == null:
		return false
	var spent: bool = false
	if currency == "gold" and currency_manager.has_method("spend_gold"):
		spent = bool(currency_manager.call("spend_gold", unlock_cost))
	elif currency_manager.has_method("spend_coins"):
		spent = bool(currency_manager.call("spend_coins", unlock_cost))
	if not spent:
		return false
	if not unlocked_banner_ids.has(id):
		unlocked_banner_ids.append(id)
	save_state()
	return true


func award_coins(amount: int) -> int:
	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager != null and currency_manager.has_method("add_coins"):
		return int(currency_manager.call("add_coins", amount))
	return get_coin_balance()


func get_shoot_sensitivity() -> float:
	return clampf(shoot_sensitivity, MIN_SHOOT_SENSITIVITY, MAX_SHOOT_SENSITIVITY)


func set_shoot_sensitivity(value: float) -> void:
	shoot_sensitivity = clampf(value, MIN_SHOOT_SENSITIVITY, MAX_SHOOT_SENSITIVITY)
	save_state()


func is_aim_inverted() -> bool:
	return aim_inverted


func set_aim_inverted(value: bool) -> void:
	aim_inverted = value
	save_state()


func get_shooting_mechanic() -> String:
	if _is_valid_shooting_mechanic(shooting_mechanic):
		return shooting_mechanic
	return DEFAULT_SHOOTING_MECHANIC


func set_shooting_mechanic(value: String) -> void:
	var clean_value: String = str(value)
	if not _is_valid_shooting_mechanic(clean_value):
		clean_value = DEFAULT_SHOOTING_MECHANIC
	shooting_mechanic = clean_value
	shooting_mechanic_prompt_seen = true
	save_state()


func has_chosen_shooting_mechanic() -> bool:
	return shooting_mechanic_prompt_seen


func mark_shooting_mechanic_prompt_seen() -> void:
	shooting_mechanic_prompt_seen = true
	save_state()


func get_shooting_mechanic_options() -> Array[Dictionary]:
	return [
		{
			"id": SHOOTING_MECHANIC_DRAG,
			"name": "Classic Drag",
			"description": "Drag from the marble to aim and set power."
		},
		{
			"id": SHOOTING_MECHANIC_SPLIT,
			"name": "Split Control",
			"description": "Left side aims. Right side controls shot power."
		},
		{
			"id": SHOOTING_MECHANIC_PRESS,
			"name": "Hold Button",
			"description": "Aim freely, then release as the power bar cycles."
		}
	]


func get_shooting_mechanic_name(value: String = "") -> String:
	var mechanic_id: String = get_shooting_mechanic() if value == "" else str(value)
	for option in get_shooting_mechanic_options():
		if str(option.get("id", "")) == mechanic_id:
			return str(option.get("name", "Classic Drag"))
	return "Classic Drag"


func _is_valid_shooting_mechanic(value: String) -> bool:
	return value == SHOOTING_MECHANIC_DRAG or value == SHOOTING_MECHANIC_SPLIT or value == SHOOTING_MECHANIC_PRESS


func get_online_server_url() -> String:
	return online_server_url


func set_online_server_url(value: String) -> void:
	online_server_url = value.strip_edges()
	save_state()


func set_player_name(new_name: String) -> void:
	var cleaned_name: String = new_name.strip_edges()
	if cleaned_name == "":
		return
	player_name = cleaned_name.left(18)
	_ensure_player_login_id()
	save_state()


func set_player_age(age: int) -> void:
	player_age = clampi(age, 0, 120)
	save_state()


func set_selected_marble(id: String) -> void:
	if marble_presets.has(id) and not _is_marble_hidden(id) and is_marble_unlocked(id):
		selected_marble_id = id
		_sync_game_manager()
		save_state()


func set_selected_trail(id: String) -> void:
	if trail_presets.has(id):
		selected_trail_id = id
		save_state()


func set_selected_banner(id: String) -> void:
	if banner_presets.has(id) and is_banner_unlocked(id):
		selected_banner_id = id
		save_state()


func set_selected_field(id: String) -> void:
	if field_presets.has(id) and is_field_unlocked(id):
		selected_field_id = id
		save_state()


func record_match_win(winner_name: String) -> void:
	var clean_name: String = winner_name.strip_edges()
	if clean_name == "":
		return
	var leaderboard_key: String = _get_leaderboard_key_for_winner(clean_name)
	var display_name: String = player_name if leaderboard_key == player_login_id and player_name.strip_edges() != "" else clean_name
	leaderboard_wins[leaderboard_key] = int(leaderboard_wins.get(leaderboard_key, 0)) + 1
	leaderboard_names[leaderboard_key] = display_name
	save_state()


func get_leaderboard_top() -> Dictionary:
	var best_name: String = ""
	var best_wins: int = 0
	for key_value in leaderboard_wins.keys():
		var key: String = str(key_value)
		var wins: int = int(leaderboard_wins.get(key, 0))
		if wins > best_wins:
			best_name = str(leaderboard_names.get(key, key))
			best_wins = wins
	return {
		"name": best_name,
		"wins": best_wins
	}


func get_leaderboard_entries() -> Array:
	var entries: Array = []
	for key_value in leaderboard_wins.keys():
		var key: String = str(key_value)
		entries.append({
			"id": key,
			"name": str(leaderboard_names.get(key, key)),
			"wins": int(leaderboard_wins.get(key, 0))
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("wins", 0)) > int(b.get("wins", 0))
	)
	return entries


func _get_leaderboard_key_for_winner(clean_name: String) -> String:
	if has_player_name() and clean_name.to_lower() == player_name.strip_edges().to_lower():
		_ensure_player_login_id()
		return player_login_id
	return clean_name


func get_google_profile_sync_payload() -> Dictionary:
	if not is_google_player_login() or player_auth_token.strip_edges() == "":
		return {}
	return {
		"auth_token": player_auth_token,
		"name": player_name,
		"player_age": player_age,
		"progress": _get_remote_progress_payload()
	}


func _get_remote_progress_payload() -> Dictionary:
	return {
		"selected_marble_id": selected_marble_id,
		"selected_trail_id": selected_trail_id,
		"selected_field_id": selected_field_id,
		"selected_banner_id": selected_banner_id,
		"shoot_sensitivity": get_shoot_sensitivity(),
		"aim_inverted": is_aim_inverted(),
		"shooting_mechanic": get_shooting_mechanic(),
		"unlocked_marble_ids": _packed_string_array_to_array(unlocked_marble_ids),
		"unlocked_field_ids": _packed_string_array_to_array(unlocked_field_ids),
		"unlocked_banner_ids": _packed_string_array_to_array(unlocked_banner_ids),
		"leaderboard_wins": leaderboard_wins,
		"leaderboard_names": leaderboard_names
	}


func _packed_string_array_to_array(values: PackedStringArray) -> Array:
	var result: Array = []
	for value in values:
		result.append(str(value))
	return result


func _apply_remote_progress(progress: Dictionary) -> void:
	var remote_unlocked_marbles: Array = progress.get("unlocked_marble_ids", []) if typeof(progress.get("unlocked_marble_ids", [])) == TYPE_ARRAY else []
	for marble_id_variant in remote_unlocked_marbles:
		var marble_id: String = str(marble_id_variant).strip_edges()
		if marble_presets.has(marble_id) and not _is_marble_hidden(marble_id) and not unlocked_marble_ids.has(marble_id):
			unlocked_marble_ids.append(marble_id)

	var remote_unlocked_fields: Array = progress.get("unlocked_field_ids", []) if typeof(progress.get("unlocked_field_ids", [])) == TYPE_ARRAY else []
	for field_id_variant in remote_unlocked_fields:
		var field_id: String = str(field_id_variant).strip_edges()
		if field_presets.has(field_id) and not unlocked_field_ids.has(field_id):
			unlocked_field_ids.append(field_id)

	var remote_unlocked_banners: Array = progress.get("unlocked_banner_ids", []) if typeof(progress.get("unlocked_banner_ids", [])) == TYPE_ARRAY else []
	for banner_id_variant in remote_unlocked_banners:
		var banner_id: String = str(banner_id_variant).strip_edges()
		if banner_presets.has(banner_id) and not unlocked_banner_ids.has(banner_id):
			unlocked_banner_ids.append(banner_id)

	var remote_marble_id: String = str(progress.get("selected_marble_id", "")).strip_edges()
	if remote_marble_id != "" and marble_presets.has(remote_marble_id) and not _is_marble_hidden(remote_marble_id) and is_marble_unlocked(remote_marble_id):
		selected_marble_id = remote_marble_id
	var remote_trail_id: String = str(progress.get("selected_trail_id", "")).strip_edges()
	if remote_trail_id != "" and trail_presets.has(remote_trail_id):
		selected_trail_id = remote_trail_id
	var remote_field_id: String = str(progress.get("selected_field_id", "")).strip_edges()
	if remote_field_id != "" and field_presets.has(remote_field_id) and is_field_unlocked(remote_field_id):
		selected_field_id = remote_field_id
	var remote_banner_id: String = str(progress.get("selected_banner_id", "")).strip_edges()
	if remote_banner_id != "" and banner_presets.has(remote_banner_id) and is_banner_unlocked(remote_banner_id):
		selected_banner_id = remote_banner_id

	if progress.has("shoot_sensitivity"):
		shoot_sensitivity = clampf(float(progress.get("shoot_sensitivity", shoot_sensitivity)), MIN_SHOOT_SENSITIVITY, MAX_SHOOT_SENSITIVITY)
	if progress.has("aim_inverted"):
		aim_inverted = bool(progress.get("aim_inverted", aim_inverted))
	var remote_mechanic: String = str(progress.get("shooting_mechanic", "")).strip_edges()
	if _is_valid_shooting_mechanic(remote_mechanic):
		shooting_mechanic = remote_mechanic

	var remote_wins: Dictionary = progress.get("leaderboard_wins", {}) if typeof(progress.get("leaderboard_wins", {})) == TYPE_DICTIONARY else {}
	var remote_names: Dictionary = progress.get("leaderboard_names", {}) if typeof(progress.get("leaderboard_names", {})) == TYPE_DICTIONARY else {}
	for key_value in remote_wins.keys():
		var key: String = str(key_value).strip_edges()
		var wins: int = int(remote_wins.get(key_value, 0))
		if key != "" and wins > int(leaderboard_wins.get(key, 0)):
			leaderboard_wins[key] = wins
			leaderboard_names[key] = str(remote_names.get(key_value, leaderboard_names.get(key, key))).strip_edges()


func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed
	var saved_version: int = int(data.get("save_version", 1))
	var marble_id: String = str(data.get("selected_marble_id", DEFAULT_MARBLE_ID))
	var trail_id: String = str(data.get("selected_trail_id", DEFAULT_TRAIL_ID))
	var field_id: String = str(data.get("selected_field_id", DEFAULT_FIELD_ID))
	var banner_id: String = str(data.get("selected_banner_id", DEFAULT_BANNER_ID))
	var saved_player_name: String = str(data.get("player_name", DEFAULT_PLAYER_NAME)).strip_edges()
	var saved_player_age: int = int(data.get("player_age", 0))
	var saved_player_login_id: String = str(data.get("player_login_id", "")).strip_edges()
	var saved_player_login_created_at: int = int(data.get("player_login_created_at", 0))
	var saved_player_auth_provider: String = str(data.get("player_auth_provider", "guest")).strip_edges()
	var saved_player_auth_email: String = str(data.get("player_auth_email", "")).strip_edges()
	var saved_player_auth_picture: String = str(data.get("player_auth_picture", "")).strip_edges()
	var saved_player_auth_token: String = str(data.get("player_auth_token", "")).strip_edges()
	var saved_shoot_sensitivity: float = float(data.get("shoot_sensitivity", DEFAULT_SHOOT_SENSITIVITY))
	var saved_aim_inverted: bool = bool(data.get("aim_inverted", DEFAULT_AIM_INVERTED))
	var saved_shooting_mechanic: String = str(data.get("shooting_mechanic", DEFAULT_SHOOTING_MECHANIC))
	var saved_shooting_prompt_seen: bool = bool(data.get("shooting_mechanic_prompt_seen", false))
	var saved_online_server_url: String = str(data.get("online_server_url", "")).strip_edges()
	var saved_leaderboard_wins: Dictionary = data.get("leaderboard_wins", {}) if typeof(data.get("leaderboard_wins", {})) == TYPE_DICTIONARY else {}
	var saved_leaderboard_names: Dictionary = data.get("leaderboard_names", {}) if typeof(data.get("leaderboard_names", {})) == TYPE_DICTIONARY else {}
	var saved_unlocked_marbles: PackedStringArray = PackedStringArray(data.get("unlocked_marble_ids", []))
	var saved_unlocked_fields: PackedStringArray = PackedStringArray(data.get("unlocked_field_ids", []))
	var saved_unlocked_banners: PackedStringArray = PackedStringArray(data.get("unlocked_banner_ids", []))
	if marble_presets.has(marble_id) and not _is_marble_hidden(marble_id):
		selected_marble_id = marble_id
	if trail_presets.has(trail_id):
		selected_trail_id = trail_id
	if field_presets.has(field_id):
		selected_field_id = field_id
	if banner_presets.has(banner_id):
		selected_banner_id = banner_id
	if saved_player_name != "":
		player_name = saved_player_name.left(18)
	player_age = clampi(saved_player_age, 0, 120)
	player_login_id = saved_player_login_id.left(40)
	player_login_created_at = saved_player_login_created_at
	player_auth_provider = saved_player_auth_provider if saved_player_auth_provider != "" else "guest"
	player_auth_email = saved_player_auth_email.left(120)
	player_auth_picture = saved_player_auth_picture.left(240)
	player_auth_token = saved_player_auth_token.left(128)
	if player_name.strip_edges() != "":
		_ensure_player_login_id()
	shoot_sensitivity = clampf(saved_shoot_sensitivity, MIN_SHOOT_SENSITIVITY, MAX_SHOOT_SENSITIVITY)
	aim_inverted = saved_aim_inverted
	shooting_mechanic = saved_shooting_mechanic if _is_valid_shooting_mechanic(saved_shooting_mechanic) else DEFAULT_SHOOTING_MECHANIC
	shooting_mechanic_prompt_seen = saved_shooting_prompt_seen
	if saved_online_server_url == "ws://127.0.0.1:24580" or saved_online_server_url == "ws://127.0.0.1:3000":
		saved_online_server_url = ""
	online_server_url = saved_online_server_url
	leaderboard_wins.clear()
	leaderboard_names.clear()
	for winner_name_value in saved_leaderboard_wins.keys():
		var original_key: String = str(winner_name_value).strip_edges()
		var winner_key: String = original_key
		var winner_name: String = str(saved_leaderboard_names.get(original_key, original_key)).strip_edges()
		if player_login_id != "" and original_key.to_lower() == player_name.strip_edges().to_lower():
			winner_key = player_login_id
			winner_name = player_name
		var wins: int = int(saved_leaderboard_wins.get(winner_name_value, 0))
		if winner_key != "" and winner_name != "" and wins > 0:
			leaderboard_wins[winner_key] = int(leaderboard_wins.get(winner_key, 0)) + wins
			leaderboard_names[winner_key] = winner_name
	unlocked_marble_ids = DEFAULT_UNLOCKED_MARBLE_IDS.duplicate()
	unlocked_field_ids = DEFAULT_UNLOCKED_FIELD_IDS.duplicate()
	unlocked_banner_ids = DEFAULT_UNLOCKED_BANNER_IDS.duplicate()
	if saved_version >= SAVE_VERSION:
		for marble_id_variant in saved_unlocked_marbles:
			var unlocked_id: String = str(marble_id_variant)
			if marble_presets.has(unlocked_id) and not _is_marble_hidden(unlocked_id) and not unlocked_marble_ids.has(unlocked_id):
				unlocked_marble_ids.append(unlocked_id)
	for field_id_variant in saved_unlocked_fields:
		var unlocked_field_id: String = str(field_id_variant)
		if field_presets.has(unlocked_field_id) and not unlocked_field_ids.has(unlocked_field_id):
			unlocked_field_ids.append(unlocked_field_id)
	for banner_id_variant in saved_unlocked_banners:
		var unlocked_banner_id: String = str(banner_id_variant)
		if banner_presets.has(unlocked_banner_id) and not unlocked_banner_ids.has(unlocked_banner_id):
			unlocked_banner_ids.append(unlocked_banner_id)
	if not is_marble_unlocked(selected_marble_id):
		selected_marble_id = DEFAULT_MARBLE_ID
	if not is_field_unlocked(selected_field_id):
		selected_field_id = DEFAULT_FIELD_ID
	if not is_banner_unlocked(selected_banner_id):
		selected_banner_id = DEFAULT_BANNER_ID
	_sync_game_manager()


func _is_marble_hidden(id: String) -> bool:
	return HIDDEN_MARBLE_IDS.has(id)


func _is_special_marble(id: String) -> bool:
	if PREMIUM_IMPORTED_MARBLE_IDS.has(id):
		return true
	var preset: Dictionary = marble_presets.get(id, {})
	return str(preset.get("type", "")).to_lower() == "premium"


func save_state() -> void:
	if has_player_name():
		_ensure_player_login_id()
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return

	var data: Dictionary = {
		"save_version": SAVE_VERSION,
		"selected_marble_id": selected_marble_id,
		"selected_trail_id": selected_trail_id,
		"selected_field_id": selected_field_id,
		"selected_banner_id": selected_banner_id,
		"player_name": player_name,
		"player_age": player_age,
		"player_login_id": player_login_id,
		"player_login_created_at": player_login_created_at,
		"player_auth_provider": get_player_auth_provider(),
		"player_auth_email": player_auth_email,
		"player_auth_picture": player_auth_picture,
		"player_auth_token": player_auth_token,
		"shoot_sensitivity": get_shoot_sensitivity(),
		"aim_inverted": is_aim_inverted(),
		"shooting_mechanic": get_shooting_mechanic(),
		"shooting_mechanic_prompt_seen": shooting_mechanic_prompt_seen,
		"online_server_url": online_server_url,
		"leaderboard_wins": leaderboard_wins,
		"leaderboard_names": leaderboard_names,
		"unlocked_marble_ids": unlocked_marble_ids,
		"unlocked_field_ids": unlocked_field_ids,
		"unlocked_banner_ids": unlocked_banner_ids
	}
	file.store_string(JSON.stringify(data))


func _sync_game_manager() -> void:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("sync_from_customization"):
		game_manager.call("sync_from_customization")
