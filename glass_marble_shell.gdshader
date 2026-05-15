shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 glass_blue : source_color = vec4(0.58, 0.8, 1.0, 0.16);
uniform vec4 swirl_orange : source_color = vec4(0.94, 0.48, 0.17, 1.0);
uniform vec4 swirl_green : source_color = vec4(0.22, 0.78, 0.34, 1.0);
uniform vec4 swirl_blue : source_color = vec4(0.07, 0.18, 0.86, 1.0);
uniform vec4 swirl_shadow : source_color = vec4(0.34, 0.09, 0.18, 1.0);
uniform float pattern_mode = 0.0;
uniform float pattern_strength = 0.0;
uniform vec4 pattern_color_a : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 pattern_color_b : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 pattern_color_c : source_color = vec4(0.1, 0.5, 0.2, 1.0);
uniform vec4 pattern_color_d : source_color = vec4(0.95, 0.95, 0.95, 1.0);

float wave_a(float x) {
	return 0.5
		+ 0.16 * sin((x - 0.08) * 6.28318 * 0.95)
		+ 0.04 * sin((x + 0.16) * 6.28318 * 2.1);
}

float wave_b(float x) {
	return 0.5
		+ 0.12 * sin((x + 0.22) * 6.28318 * 1.35)
		+ 0.03 * sin((x - 0.18) * 6.28318 * 2.8);
}

void fragment() {
	vec2 uv = UV;
	float main_center = wave_a(uv.x);
	float accent_center = wave_b(uv.x);

	float main_dist = abs(uv.y - main_center);
	float accent_dist = abs(uv.y - accent_center);
	float blue_dist = abs(uv.y - (main_center + 0.035));
	float shadow_dist = abs(uv.y - (main_center - 0.05));

	float main_band = smoothstep(0.18, 0.05, main_dist);
	float main_core = smoothstep(0.11, 0.018, main_dist);
	float accent_band = smoothstep(0.11, 0.028, accent_dist);
	float blue_band = smoothstep(0.05, 0.014, blue_dist);
	float shadow_band = smoothstep(0.06, 0.02, shadow_dist) * (1.0 - main_band * 0.35);

	float main_gradient = clamp((uv.y - (main_center - 0.08)) / 0.16, 0.0, 1.0);
	vec3 main_color = mix(swirl_orange.rgb, swirl_green.rgb, main_gradient);
	vec3 color = glass_blue.rgb;
	color = mix(color, main_color, main_band);
	color = mix(color, main_color * 0.74, main_core * 0.35);
	color = mix(color, swirl_blue.rgb, blue_band);
	color = mix(color, swirl_shadow.rgb, shadow_band * 0.8);
	color = mix(color, mix(swirl_green.rgb, swirl_orange.rgb, 0.6), accent_band * 0.45);

	float pattern_mask = 0.0;
	vec3 pattern_color = color;
	float warped_y = uv.y + sin(uv.x * 6.28318 * 1.25) * 0.035;
	float warped_x = uv.x + sin(uv.y * 6.28318 * 0.9) * 0.05;

	if (pattern_mode > 0.5 && pattern_mode < 1.5) {
		float top_band = smoothstep(0.24, 0.18, abs(warped_y - 0.24));
		float red_band = smoothstep(0.20, 0.16, abs(warped_y - 0.50));
		float green_band = smoothstep(0.24, 0.18, abs(warped_y - 0.77));
		float white_sep_a = smoothstep(0.04, 0.015, abs(warped_y - 0.37));
		float white_sep_b = smoothstep(0.04, 0.015, abs(warped_y - 0.63));
		float dark_core = smoothstep(0.09, 0.03, abs(uv.x - 0.5)) * smoothstep(0.17, 0.01, abs(warped_y - 0.5));

		pattern_color = mix(pattern_color, pattern_color_a.rgb, top_band);
		pattern_color = mix(pattern_color, pattern_color_b.rgb, red_band);
		pattern_color = mix(pattern_color, pattern_color_c.rgb, green_band);
		pattern_color = mix(pattern_color, pattern_color_d.rgb, max(white_sep_a, white_sep_b));
		pattern_color = mix(pattern_color, pattern_color_a.rgb, dark_core * 0.8);
		pattern_mask = max(max(top_band, red_band), max(green_band, max(white_sep_a, white_sep_b)));
		pattern_mask = max(pattern_mask, dark_core * 0.75);
	} else if (pattern_mode > 1.5 && pattern_mode < 2.5) {
		float starfield = pow(max(0.0, sin((warped_x * 17.0 + warped_y * 13.0) * 6.28318)), 18.0);
		float orbit = smoothstep(0.06, 0.01, abs(uv.y - wave_b(uv.x)));
		float flare = smoothstep(0.08, 0.02, abs(uv.y - wave_a(uv.x + 0.18)));

		pattern_color = mix(pattern_color, pattern_color_a.rgb, starfield);
		pattern_color = mix(pattern_color, pattern_color_b.rgb, flare * 0.65);
		pattern_color = mix(pattern_color, pattern_color_c.rgb, orbit * 0.55);
		pattern_mask = max(starfield * 0.95, max(orbit * 0.55, flare * 0.65));
	} else if (pattern_mode > 2.5) {
		float stripe_wave = sin((warped_x * 10.5 + warped_y * 6.5) * 6.28318);
		float stripe_mask = smoothstep(0.68, 0.92, stripe_wave);
		float soft_mask = smoothstep(0.18, 0.52, stripe_wave);

		pattern_color = mix(pattern_color, pattern_color_a.rgb, stripe_mask);
		pattern_color = mix(pattern_color, pattern_color_b.rgb, (1.0 - stripe_mask) * soft_mask * 0.38);
		pattern_color = mix(pattern_color, pattern_color_c.rgb, soft_mask * 0.15);
		pattern_mask = max(stripe_mask, soft_mask * 0.28);
	}

	color = mix(color, pattern_color, clamp(pattern_strength, 0.0, 1.0) * pattern_mask);

	float gloss_variation = 0.5 + 0.5 * sin((uv.x * 12.0 + uv.y * 7.0) * 1.05);
	color = mix(color, glass_blue.rgb + vec3(0.03, 0.05, 0.08), gloss_variation * 0.05);

	ALBEDO = color;
	METALLIC = 0.01;
	ROUGHNESS = mix(0.06, 0.14, accent_band * 0.2);
	SPECULAR = 0.72;
	EMISSION = main_color * main_core * 0.015 + swirl_blue.rgb * blue_band * 0.012;
}
