shader_type spatial;

uniform vec2 tiling = vec2(2.0, 1.0);
uniform vec2 offset = vec2(0.0, 0.0);
uniform vec2 scroll_speed = vec2(0.1, 0.0);
uniform bool moving = false;
uniform sampler2D moja_tekstura : repeat_enable;
uniform float brightness : hint_range(-1.0, 1.0, 0.1) = 0;
varying vec3 world_pos;
varying vec3 world_normal;

vec2 turn_tile(vec2 uv_in, vec2 pivot, float rotation_degrees){
	uv_in -= pivot;
	float rotation_radians = radians(rotation_degrees);
	float c = cos(rotation_radians);
	float s = sin(rotation_radians);
	
	vec2 uv_out;

	uv_out.x = uv_in.x * c + uv_in.y * s;
	uv_out.y = uv_in.y * c - uv_in.x * s;

	uv_out += pivot;
	
	return uv_out;
}

mat4 brighteness_matrix(float b){
	return mat4(
		vec4(1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, 1, 0),
		vec4(b, b, b, 1)	
	);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = abs(NORMAL);
}

void fragment() {
    vec3 blending = world_normal;
    blending /= (blending.x + blending.y + blending.z);
	
	vec2 current_offset = offset;
	if (moving) {
        current_offset += scroll_speed * TIME;
    }
	vec2 uv_x = world_pos.zy * tiling + current_offset;
    vec2 uv_y = world_pos.xz * tiling + current_offset;
    vec2 uv_z = world_pos.xy * tiling + current_offset;

    uv_x = turn_tile(uv_x, vec2(0.5), 90);
    uv_y = turn_tile(uv_y, vec2(0.5), 90);
    uv_z = turn_tile(uv_z, vec2(0.5), 90);
	
	vec3 x_tex = texture(moja_tekstura, uv_x).rgb;
    vec3 y_tex = texture(moja_tekstura, uv_y).rgb;
    vec3 z_tex = texture(moja_tekstura, uv_z).rgb;
 
    mat4 matrix = brighteness_matrix(brightness);
	vec3 base_color = (x_tex * blending.x + y_tex * blending.y + z_tex * blending.z);
    ALBEDO = (matrix * vec4(base_color, 1.0)).rgb;
}



