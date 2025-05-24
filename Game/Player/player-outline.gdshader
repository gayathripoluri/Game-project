shader_type canvas_item;

uniform float outline_width = 0.002; // Controls outline thickness
uniform vec4 outline_color = vec4(1.0, 0.7, 0.7, 1.0); // Romantic pink outline
uniform float outline_opacity = 1.0; // Controls outline transparency

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
    float outline = 0.0;

    if (color.a == 0.0) {
        for (float x = -1.0; x <= 1.0; x += 1.0) {
            for (float y = -1.0; y <= 1.0; y += 1.0) {
                vec2 offset = vec2(x, y) * pixel_size * outline_width;
                outline += texture(TEXTURE, UV + offset).a;
            }
        }
    }
    outline = clamp(outline, 0.0, 1.0);
    vec4 final_color = mix(color, outline_color, outline * outline_opacity * (1.0 - color.a));
    COLOR = final_color;
}