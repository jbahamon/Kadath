
shader_type canvas_item;
render_mode blend_add;

uniform vec3 tint_color : source_color = vec3(1.0, 0.0, 1.0);
uniform float intensity : hint_range(0, 1) = 0.3;
uniform float alpha: hint_range(0.0, 1.0) = 1.0;
uniform vec4 add = vec4(0.0);
	
void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	float avg = ((pixelColor.r + pixelColor.g + pixelColor.b) / 3.0);
	
	avg = mod(avg - TIME * 2.0, 1.0);
	vec4 front = vec4(vec3(avg), min(pixelColor.a, alpha));
	COLOR = mix(front, vec4(tint_color, front.a), intensity) + add;
}