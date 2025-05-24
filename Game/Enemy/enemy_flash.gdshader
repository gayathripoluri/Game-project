shader_type canvas_item;

uniform bool is_hit = false; // Use 'false' instead of 0
uniform float flash_intensity = 0.7; // Flash strength
uniform vec4 flash_color = vec4(1.0, 1.0, 1.0, 1.0); // White flash

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    if (is_hit) {
        COLOR = mix(color, flash_color, flash_intensity * color.a);
    } else {
        COLOR = color;
    }
}
