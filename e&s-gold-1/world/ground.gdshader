shader_type spatial;

uniform vec3 grass_color : source_color = vec3(0.1, 0.6, 0.1);
uniform vec3 dirt_color : source_color = vec3(0.4, 0.25, 0.1);
// vars for blending the grass and dirt
uniform float transition_start : hint_range(0.0, 1.0) = 0.0;
uniform float transition_end : hint_range(0.0, 1.0) = 0.6;

uniform sampler2D noise;
uniform sampler2D normal_map;
uniform float height_scale = 1.5;

varying vec2 tex_position;
varying float v_noise_height;

void vertex() {
	tex_position = VERTEX.xz / 2.0 + 0.5;
	float height = texture(noise, tex_position).x;
	VERTEX.y += height * height_scale;

	// Pass the noise height to the fragment shader
	v_noise_height = height;
	
}

void fragment() {
	// smoothstep makes the transition smoother
	float mix_factor = smoothstep(transition_start, transition_end, v_noise_height);

	// Interpolate between the dirt and the grass colour using the mix_factor.
	vec3 final_color = mix(dirt_color.rgb, grass_color.rgb, mix_factor);
	
	// colour the fragment
	ALBEDO = final_color;

	// Apply the normal map
	NORMAL_MAP = texture(normal_map, tex_position).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//}
