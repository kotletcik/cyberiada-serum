shader_type spatial;

uniform vec2 tiling = vec2(2.0, 1.0);
uniform vec2 offset = vec2(0.0, 0.0);
uniform vec2 scroll_speed = vec2(0.1, 0.0);
uniform bool moving = false;
uniform sampler2D texture_map : repeat_enable;
uniform float brightness : hint_range(-1.0, 1.0, 0.01) = 0;
uniform vec3 color = vec3(0.0,0.0,0.0);
uniform sampler2D normal_map;
uniform sampler2D roughness_map;
uniform sampler2D metallic_map;
varying vec3 world_pos;
varying vec3 world_normal;


float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

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
	
	if (rand(floor(uv_x)) > 0.5) {
        uv_x = turn_tile(uv_x, vec2(0.5), 90);
    }
    if (rand(floor(uv_y)) > 0.5) {
        uv_y = turn_tile(uv_y, vec2(0.5), 90);
    }
    if (rand(floor(uv_z)) > 0.5) {
        uv_z = turn_tile(uv_z, vec2(0.5), 90);
    }
	
	vec3 x_tex = texture(texture_map, uv_x).rgb;
    vec3 y_tex = texture(texture_map, uv_y).rgb;
    vec3 z_tex = texture(texture_map, uv_z).rgb;
	
	vec3 x_nor = texture(normal_map, uv_x).rgb;
    vec3 y_nor = texture(normal_map, uv_y).rgb;
    vec3 z_nor = texture(normal_map, uv_z).rgb;
	
	vec3 x_r = texture(roughness_map, uv_x).rgb;
    vec3 y_r = texture(roughness_map, uv_y).rgb;
    vec3 z_r = texture(roughness_map, uv_z).rgb;
	
	vec3 x_m = texture(metallic_map, uv_x).rgb;
    vec3 y_m = texture(metallic_map, uv_y).rgb;
    vec3 z_m = texture(metallic_map, uv_z).rgb;
 
    mat4 matrix = brighteness_matrix(brightness);
	vec3 base_color = (x_tex * blending.x + y_tex * blending.y + z_tex * blending.z) * color;
	vec3 mixed_normal = (x_nor * blending.x + y_nor * blending.y + z_nor * blending.z);
    
 
    NORMAL_MAP = mixed_normal;
    
   
    //NORMAL_MAP_DEPTH = 1.5; 

    
    ROUGHNESS = (x_r * blending.x + y_r * blending.y + z_r * blending.z).r;
    METALLIC = (x_m * blending.x + y_m * blending.y + z_m * blending.z).r;
	
    ALBEDO = (matrix * vec4(base_color, 1.0)).rgb;
	
}



