shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 color_a : source_color = vec4(0.92, 0.52, 0.24, 1.0);
uniform vec4 color_b : source_color = vec4(0.22, 0.72, 0.92, 1.0);
uniform vec4 color_c : source_color = vec4(0.18, 0.24, 0.86, 1.0);
uniform vec4 accent_color : source_color = vec4(1.0, 0.96, 0.84, 1.0);
uniform vec4 emission_color : source_color = vec4(0.34, 0.72, 1.0, 1.0);
uniform float emission_strength : hint_range(0.0, 1.4) = 0.0;
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.92;
uniform float swirl_scale : hint_range(2.0, 16.0) = 6.2;
uniform float swirl_strength : hint_range(0.0, 0.5) = 0.18;
uniform float roughness_hint : hint_range(0.02, 1.0) = 0.08;

void fragment() {
	vec2 uv = UV;
	float wave = sin((uv.x * swirl_scale + uv.y * (swirl_scale * 0.55)) * 6.28318);
	uv.y += wave * swirl_strength * 0.12;
	float band_a = smoothstep(0.14, 0.0, abs(uv.y - 0.34 - sin(uv.x * 5.4) * 0.08));
	float band_b = smoothstep(0.12, 0.0, abs(uv.y - 0.66 + sin(uv.x * 4.1 + 0.8) * 0.06));
	vec3 color = mix(color_a.rgb, color_b.rgb, clamp(uv.y, 0.0, 1.0));
	color = mix(color, color_c.rgb, band_b * 0.75);
	color = mix(color, accent_color.rgb, band_a * 0.42);
	float fresnel = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 2.0);
	ALBEDO = mix(color, accent_color.rgb, fresnel * 0.16);
	ROUGHNESS = roughness_hint;
	METALLIC = 0.0;
	SPECULAR = 0.82;
	EMISSION = emission_color.rgb * emission_strength;
	ALPHA = alpha_strength;
}
