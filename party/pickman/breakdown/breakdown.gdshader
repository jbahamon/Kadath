shader_type canvas_item;

uniform vec3 luminosity: source_color = vec3(0.299, 0.587, 0.114);
uniform float frequency = 1;
uniform vec4 outline_color: source_color;


void fragment(){
	float phase = 0.5 + 0.5 * cos(2.0 * frequency * float(TIME * PI));
	vec4 sprite_color = texture(TEXTURE, UV);
	if (sprite_color.r < 0.001 && sprite_color.g < 0.001 && sprite_color.b < 0.001 && sprite_color.a > 0.0) {
		COLOR = mix(outline_color, sprite_color, phase);
	} else {
		vec3 gray = vec3(dot(luminosity, COLOR.rgb));
		COLOR = vec4(mix(COLOR.rgb, gray, phase), COLOR.a);
		
	}
	
}