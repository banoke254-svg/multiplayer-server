shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 grass_bottom : source_color = vec4(0.12, 0.34, 0.10, 1.0);
uniform vec4 grass_mid : source_color = vec4(0.19, 0.52, 0.16, 1.0);
uniform vec4 grass_tip : source_color = vec4(0.42, 0.72, 0.26, 1.0);
uniform float sway_strength = 0.07;
uniform float sway_speed = 1.05;
uniform vec3 wind_direction = vec3(0.92, 0.0, 0.28);
uniform float gust_strength = 0.03;

float hash11(float n) {
	return fract(sin(n) * 43758.5453123);
}

void vertex() {
	float sway_mask = UV.y * UV.y;
	vec2 wind = normalize(max(abs(wind_direction.xz), vec2(0.001)) * sign(wind_direction.xz));
	float instance_seed = hash11(float(INSTANCE_ID) * 0.173);
	float phase = TIME * sway_speed + float(INSTANCE_ID) * 0.73 + VERTEX.x * 3.2;
	float gust = sin(TIME * 0.75 + float(INSTANCE_ID) * 0.17 + VERTEX.y * 2.6) * 0.5 + 0.5;
	float sway = sin(phase) * sway_strength + gust * gust_strength;
	VERTEX.x += wind.x * sway * sway_mask;
	VERTEX.z += wind.y * sway * 0.8 * sway_mask;
	VERTEX.x += sin(phase * 0.6 + instance_seed * 6.28) * sway_strength * 0.12 * sway_mask;
	VERTEX.z += cos(phase * 0.52 + instance_seed * 6.28) * sway_strength * 0.12 * sway_mask;
}

void fragment() {
	vec2 uv = UV;
	float blade_a = smoothstep(0.48, 0.14, abs(uv.x - 0.24) + (1.0 - uv.y) * 0.08);
	float blade_b = smoothstep(0.44, 0.12, abs(uv.x - 0.5) + (1.0 - uv.y) * 0.1);
	float blade_c = smoothstep(0.5, 0.15, abs(uv.x - 0.76) + (1.0 - uv.y) * 0.07);
	float notch = smoothstep(0.0, 0.32, uv.y);
	float alpha = max(max(blade_a, blade_b), blade_c) * notch;
	alpha *= 1.0 - smoothstep(0.9, 1.0, abs(uv.x - 0.5) * 1.3 + uv.y * 0.18);

	vec3 color = mix(grass_bottom.rgb, grass_mid.rgb, smoothstep(0.08, 0.58, uv.y));
	color = mix(color, grass_tip.rgb, smoothstep(0.56, 1.0, uv.y));
	float shade = 0.84 + 0.16 * sin((uv.x * 17.0 + uv.y * 6.0) * 1.1);
	color *= shade;

	ALBEDO = color;
	ALPHA = alpha;
	ALPHA_SCISSOR_THRESHOLD = 0.38;
	ROUGHNESS = mix(0.9, 0.72, smoothstep(0.42, 1.0, uv.y));
	SPECULAR = 0.16;
}
