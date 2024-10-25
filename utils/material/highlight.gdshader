shader_type canvas_item;

uniform vec4 add: source_color = vec4(1, 1, 1, 0);
uniform float mul = 0.25;
uniform float frequency = 1;
uniform vec4 base_add : source_color = vec4(0, 0, 0, 0);


void fragment(){
  COLOR = texture(TEXTURE, UV) *1.25 + base_add + add * mul * vec4(vec3(sin(2.0 * frequency * float(TIME * PI))), 0) ;
}