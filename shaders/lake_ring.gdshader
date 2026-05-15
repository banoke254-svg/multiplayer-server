shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

uniform vec2 inner_half_extents = vec2(22.0, 24.0);
uniform float edge_feather = 3.2;
uniform vec4 shallow_color : source_color = vec4(0.08, 0.34, 0.42, 1.0);
uniform vec4 deep_color : source_color = vec4(0.03, 0.12, 0.18, 1.0);
uniform vec4 foam_color : source_color = vec4(0.78, 0.94, 1.0, 1.0);
uniform float wave_scale = 0.085;
uniform float wave_speed = 0.42;
uniform float wave_height = 0.2;
uniform float metallic_bias = 0.05;
uniform float roughness_min = 0.04;
uniform float roughness_max = 0.22;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void vertex() {
	vec2 p = VERTEX.xz;
	float outside_x = smoothstep(inner_half_extents.x - edge_feather, inner_half_extents.x + edge_feather, abs(p.x));
	float outside_z = smoothstep(inner_half_extents.y - edge_feather, inner_half_extents.y + edge_feather, abs(p.y));
	float water_mask = max(outside_x, outside_z);

	float time = TIME * wave_speed;
	float wave_a = sin((p.x + time * 8.0) * wave_scale) * cos((p.y - time * 5.0) * wave_scale * 1.3);
	float wave_b = noise(p * wave_scale * 0.9 + vec2(time * 0.8, -time * 0.5)) * 2.0 - 1.0;
	VERTEX.y += (wave_a * 0.6 + wave_b * 0.4) * wave_height * water_mask;
}

void fragment() {
	vec2 p = VERTEX.xz;
	float outside_x = smoothstep(inner_half_extents.x - edge_feather, inner_half_extents.x + edge_feather, abs(p.x));
	float outside_z = smoothstep(inner_half_extents.y - edge_feather, inner_half_extents.y + edge_feather, abs(p.y));
	float water_mask = max(outside_x, outside_z);

	float time = TIME * wave_speed;
	float ripple = noise(p * wave_scale * 1.4 + vec2(time * 1.8, time * 0.7));
	float swell = noise(p * wave_scale * 0.5 - vec2(time * 0.3, time * 0.45));
	vec3 water_color = mix(shallow_color.rgb, deep_color.rgb, clamp(swell * 1.15, 0.0, 1.0));

	float border_dist = min(abs(abs(p.x) - inner_half_extents.x), abs(abs(p.y) - inner_half_extents.y));
	float foam = (1.0 - smoothstep(0.0, edge_feather * 0.95, border_dist)) * water_mask;
	foam *= 0.55 + ripple * 0.45;

	ALBEDO = mix(water_color, foam_color.rgb, foam * 0.45);
	ROUGHNESS = mix(roughness_min, roughness_max, ripple * 0.55);
	METALLIC = metallic_bias;
	SPECULAR = 0.92;
	EMISSION = foam_color.rgb * foam * 0.08;
	ALPHA = clamp(water_mask, 0.0, 1.0);
}
