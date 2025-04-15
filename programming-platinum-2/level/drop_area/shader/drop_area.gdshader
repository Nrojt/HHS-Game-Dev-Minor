shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_disabled;

// Base color and transparency of the area
uniform vec4 base_color : source_color = vec4(0.1, 0.3, 0.8, 0.3);
// Color and transparency of the lines
uniform vec4 line_color : source_color = vec4(0.7, 0.9, 1.0, 0.7);

// Noise texture used to generate the lines (Needs a texture assigned in the material)

uniform sampler2D noise_texture : hint_default_white;

// How zoomed-in the noise pattern is (smaller value = larger pattern)
uniform float noise_scale : hint_range(0.1, 20.0) = 5.0;
// Speed at which the lines move
uniform float noise_speed : hint_range(0.0, 1.0) = 0.05;
// Direction of movement
uniform vec2 noise_direction = vec2(0.7, 1.0);

// Controls the thickness and softness of the lines
uniform float line_threshold_low : hint_range(0.0, 1.0) = 0.38;
// Higher threshold = softer transition to lines
uniform float line_threshold_high : hint_range(0.0, 1.0) = 0.62;


void fragment() {

	// Normalize direction vector
	vec2 direction = normalize(noise_direction);
	// Calculate UV coordinates for sampling the noise texture and make it move
	vec2 noise_uv = UV * noise_scale + TIME * noise_speed * direction;

	// Sample the noise texture (using the red channel, common for grayscale noise)
	float noise_value = texture(noise_texture, noise_uv).r;

	float line_mask = smoothstep(line_threshold_low, line_threshold_high, noise_value);

	// Mix between the base_color and the line_color using the line_mask.
	vec4 final_color = mix(base_color, line_color, line_mask);


	// Set the final colour and transparency
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;

	// Make it glow a little
	EMISSION = final_color.rgb;
}