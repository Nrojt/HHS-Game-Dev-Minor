shader_type spatial;
uniform vec3 color_a = vec3(1.0, 0.0, 0.4);
uniform vec3 color_b = vec3(0.0, 1.0, 0.0);
uniform float speed = 1.0;
uniform float wave_amplitude = 0.2;
uniform float wave_frequency = 4.0;

void vertex() {
    float wave = sin(TIME * speed + VERTEX.x * wave_frequency) * wave_amplitude;
    VERTEX.y += wave;
}

void fragment() {
    // Diagonal gradient
	float diagonal_gradient = (UV.x + UV.y + TIME * speed);
    float pattern = smoothstep(0.2, 0.8, fract(diagonal_gradient));

    // Mix colors with the pattern
    vec3 mix_colour = mix(color_a, color_b, pattern);

	// Apply the mixed color to the albedo
    ALBEDO = mix_colour;
    METALLIC = pattern * 0.5;
    ROUGHNESS = 1.0 - pattern * 0.3;
}
