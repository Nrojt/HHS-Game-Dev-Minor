shader_type sky;
render_mode use_half_res_pass;

// The color at the lower part of the sky gradient.
uniform vec3 sky_color_horizon : source_color = vec3(0.4, 0.0, 1.0);
uniform vec3 sky_color_zenith : source_color = vec3(0.0, 0.4, 1.0);
// The base color of the clouds.
uniform vec3 cloud_color : source_color = vec3(1.0, 1.0, 1.0);
// Cloud opacity range, used to determine how opaque the clouds are.
uniform float cloud_min = 0.3;
uniform float cloud_max = 0.8;
// How fast the clouds scroll horizontally across the sky.
uniform float cloud_speed = 0.01;
// Making the clouds semi transparent. Also turns the fully opaque clouds semi transparent.
uniform float cloud_transparency = 0.3;
// The 2D texture used to generate the cloud shapes.
uniform sampler2D cloud_noise;

// TODO: see if I can remove the line between tiles (prob won't bother).

// Sky gradient function
vec3 generate_sky(vec3 eyedir) {
    // Create gradient, based on the look direction
    float horizon = smoothstep(-0.1, 0.5, eyedir.y);
    // Mixing zenith and horizon with the look direction
    return mix(
        sky_color_horizon,
        sky_color_zenith,
        horizon
    );
}

// Generate clouds based on noise texture
vec4 generate_clouds(vec3 eyedir) {
	// Create UV coordinates based on look direction, dividing to get a curved effect
    vec2 uv = eyedir.xz / (eyedir.y + 1.0);

    // time-based movement, making the clouds move over the sky
    uv.x += TIME * cloud_speed;

	// Combat the tiling effect by wrapping the UV coordinates
    uv = fract(uv);

    // Sample noise texture
    float noise = texture(cloud_noise, uv).r;

    // generate clouds
    float clouds = smoothstep(cloud_min, cloud_max, noise);

    return vec4(cloud_color, clouds * cloud_transparency);
}

void sky() {
    if (AT_HALF_RES_PASS) {
        vec4 color = generate_clouds(EYEDIR);
        COLOR = color.rgb;
        ALPHA = color.a;
    } else {
        vec3 color = generate_sky(EYEDIR);
        COLOR = color + HALF_RES_COLOR.rgb * HALF_RES_COLOR.a;
    }
}
