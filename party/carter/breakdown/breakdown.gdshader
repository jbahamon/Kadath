shader_type canvas_item;

uniform float frequency = 1;
uniform vec4 outline_color: source_color;

uniform float shake_intensity = 1.0;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
        vec2 random_offset = vec2(
            rand(vec2(TIME, 0.0)) * 2.0 - 1.0,
            0.0
        );
        VERTEX += random_offset * shake_intensity;

}

void fragment(){
	vec4 sprite_color = texture(TEXTURE, UV);
	if (sprite_color.r < 0.001 && sprite_color.g < 0.001 && sprite_color.b < 0.001 && sprite_color.a > 0.0) {
		COLOR = mix(outline_color, sprite_color, 0.5 + 0.5 * cos(2.0 * frequency * float(TIME * PI)));
	} else {
		COLOR = sprite_color;
	}

}