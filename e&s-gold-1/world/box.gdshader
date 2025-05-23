shader_type spatial;
// The colours the box will shift through
uniform vec3 color_a : source_color = vec3(1.0, 0.0, 0.4);
uniform vec3 color_b : source_color = vec3(0.0, 1.0, 0.0);

// The speed of the wave effect
uniform float speed = 1.0;
// The amplitude and frequency of the wave effect
uniform float wave_amplitude = 0.2;
uniform float wave_frequency = 4.0;

uniform vec3 flash_colour = vec3(1.0, 1.0, 1.0);
// To be set by code, makes the box flash the above colour
uniform bool flash = false;

void vertex() {
	// Apply the wave effect to the vertex position, based on time, to make it move
    float wave = sin(TIME * speed + VERTEX.x * wave_frequency) * wave_amplitude;
    VERTEX.y += wave;
}

void fragment() {
    if (flash) {
        // Make the box the flash colour. Alpha is not required here, so simple seting colour
        ALBEDO = flash_colour;
    } else {
        // Diagonal gradient
        float diagonal_gradient = (UV.x + UV.y + TIME * speed);
        float pattern = smoothstep(0.2, 0.8, fract(diagonal_gradient));

        // Mix colors with the pattern
        vec3 mix_colour = mix(color_a, color_b, pattern);

        // Apply the mixed color, setting slight metallic and roughness
        ALBEDO = mix_colour;
        METALLIC = pattern * 0.5;
        ROUGHNESS = 1.0 - pattern * 0.3;
    }
}

