shader_type spatial;
render_mode blend_mix, cull_disabled;

uniform sampler2D glow_texture : source_color;
uniform vec4 glow_color : source_color = vec4(0.38, 0.78, 1.0, 1.0);
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.34;
uniform float emission_strength : hint_range(0.0, 2.0) = 0.45;

void fragment() {
	vec4 tex = texture(glow_texture, UV);
	vec3 color = glow_color.rgb * tex.a;
	ALBEDO = color;
	EMISSION = vec3(0.0);
	ALPHA = 0.0;
}
