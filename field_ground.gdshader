shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

varying vec3 world_pos;

uniform vec4 fairway_base : source_color = vec4(0.36, 0.67, 0.25, 1.0);
uniform vec4 fairway_light : source_color = vec4(0.58, 0.82, 0.38, 1.0);
uniform vec4 fairway_dark : source_color = vec4(0.22, 0.46, 0.14, 1.0);
uniform vec4 dry_patch : source_color = vec4(0.58, 0.68, 0.28, 1.0);
uniform float stripe_scale = 18.0;
uniform float noise_scale = 24.0;
uniform float damp_detail_strength = 0.12;
uniform float sun_warmth = 0.06;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
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
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 field_uv = world_pos.xz;
	float stripes = 0.5 + 0.5 * sin(field_uv.x * stripe_scale * 0.1);
	float patch_noise = noise(field_uv * (noise_scale * 0.1));
	float broad_noise = noise(field_uv * (noise_scale * 0.035));
	float fine_noise = noise(field_uv * (noise_scale * 0.18));
	float damp_mask = smoothstep(0.38, 0.92, fine_noise * 0.65 + broad_noise * 0.35);

	vec3 color = mix(fairway_dark.rgb, fairway_light.rgb, stripes * 0.35 + 0.3);
	color = mix(color, fairway_base.rgb, 0.55);
	color = mix(color, dry_patch.rgb, smoothstep(0.7, 1.0, patch_noise) * 0.12);
	color *= 0.9 + broad_noise * 0.18;
	color = mix(color, color * vec3(0.82, 0.92, 0.86), damp_mask * damp_detail_strength);
	color += vec3(sun_warmth, sun_warmth * 0.75, sun_warmth * 0.38) * smoothstep(0.48, 0.92, stripes) * 0.18;

	ALBEDO = color;
	ROUGHNESS = mix(0.98, 0.84, damp_mask * 0.7);
	SPECULAR = mix(0.04, 0.14, damp_mask * 0.55);
}
