shader_type canvas_item;

uniform float frequency = 2;


void fragment(){
  COLOR = vec4(COLOR.rgb, 0.5 + 0.5 * cos(2.0 * frequency * float(TIME * PI)));
}