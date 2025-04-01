shader_type spatial;
	
uniform vec3 grass_color : source_color = vec3(0.1, 0.6, 0.1);
uniform vec3 dirt_color : source_color = vec3(0.4, 0.25, 0.1);
uniform float grass_shadow : hint_range(0.0, 2.0) = 1.2;
uniform float dirt_shadow : hint_range(0.0, 2.0) = 0.8;
// vars for blending the grass and dirt
uniform float transition_start : hint_range(0.0, 1.0) = 0.3;  
uniform float transition_end : hint_range(0.0, 1.0) = 0.8;  

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
	// Mixing the colour based on the noise height and the transition range
    float mix_factor = smoothstep(transition_start, transition_end, v_noise_height);
    vec3 final_color = mix(dirt_color.rgb, grass_color.rgb, mix_factor);
    
    // Applying the color
    ALBEDO = final_color;
    // Applying the normal map
    NORMAL_MAP = texture(normal_map, tex_position).xyz;
}

void light() {
    // Calculate shadow softness
    float shadow_softness = 1.0 - smoothstep(transition_start, transition_end, v_noise_height);
    
    // Apply shadow softness, based on the terrain
    vec3 light_contrib = LIGHT_COLOR * ATTENUATION * max(0.0, dot(NORMAL, LIGHT));
    light_contrib *= mix(grass_shadow, dirt_shadow, shadow_softness);
    
    // Add to diffuse light
    DIFFUSE_LIGHT += light_contrib;
}


