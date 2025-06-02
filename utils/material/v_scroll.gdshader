shader_type canvas_item;

uniform vec2 offset;
uniform float opacity;

void fragment() {
	COLOR = texture(TEXTURE, vec2(mod(UV + offset, 1.0)));
	COLOR.a = min(opacity, COLOR.a);
}
