shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 body_tint : source_color = vec4(0.44, 0.72, 0.98, 0.08);
uniform vec4 ribbon_orange : source_color = vec4(0.90, 0.47, 0.16, 1.0);
uniform vec4 ribbon_green : source_color = vec4(0.19, 0.79, 0.30, 1.0);
uniform vec4 ribbon_blue : source_color = vec4(0.05, 0.15, 0.84, 1.0);
uniform vec4 ribbon_shadow : source_color = vec4(0.34, 0.10, 0.20, 1.0);
uniform float phase_offset = 0.0;
uniform float primary_wave_scale = 0.9;
uniform float secondary_wave_scale = 2.0;
uniform float primary_amplitude = 0.17;
uniform float secondary_amplitude = 0.04;
uniform float band_width = 0.045;
uniform float core_width = 0.02;
uniform float stripe_offset = 0.035;
uniform float shadow_offset = -0.04;

float ribbon_center(float x) {
	return 0.5
		+ sin((x - 0.1 + phase_offset) * 6.28318 * primary_wave_scale) * primary_amplitude
		+ sin((x + 0.14 - phase_offset * 0.5) * 6.28318 * secondary_wave_scale) * secondary_amplitude;
}

void fragment() {
	vec2 uv = UV;
	float center = ribbon_center(uv.x);
	float dist_main = abs(uv.y - center);
	float main_band = smoothstep(band_width + 0.135, band_width, dist_main);
	float core_band = smoothstep(core_width + 0.09, core_width, dist_main);

	float blue_center = center + stripe_offset;
	float dist_blue = abs(uv.y - blue_center);
	float blue_band = smoothstep(0.05, 0.016, dist_blue);

	float shadow_center = center + shadow_offset;
	float dist_shadow = abs(uv.y - shadow_center);
	float shadow_band = smoothstep(0.07, 0.02, dist_shadow) * (1.0 - main_band * 0.35);

	float main_gradient = clamp((uv.y - (center - 0.075)) / 0.15, 0.0, 1.0);
	vec3 main_color = mix(ribbon_orange.rgb, ribbon_green.rgb, main_gradient);
	vec3 color = body_tint.rgb;
	color = mix(color, main_color, main_band);
	color = mix(color, main_color * 0.72, core_band * 0.25);
	color = mix(color, ribbon_blue.rgb, blue_band);
	color = mix(color, ribbon_shadow.rgb, shadow_band * 0.8);

	float soft_swirl = 0.5 + 0.5 * sin((uv.x * 10.0 + uv.y * 6.0) * 1.15);
	color = mix(color, body_tint.rgb + vec3(0.04, 0.06, 0.08), soft_swirl * 0.06);

	float alpha = 0.04;
	alpha = mix(alpha, 0.62, main_band);
	alpha = max(alpha, core_band * 0.72);
	alpha = max(alpha, blue_band * 0.88);
	alpha = max(alpha, shadow_band * 0.32);

	ALBEDO = color;
	ALPHA = alpha;
	METALLIC = 0.01;
	ROUGHNESS = 0.08;
	SPECULAR = 0.82;
	EMISSION = main_color * core_band * 0.05 + ribbon_blue.rgb * blue_band * 0.03;
}
