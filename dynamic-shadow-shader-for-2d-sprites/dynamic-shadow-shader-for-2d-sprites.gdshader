/**
Dynamic Shadow Shader for 2D Sprites

This shader adds a simple shadow effect to 2D sprites, making use of a duplicated `TextureRect` node with an assigned shadow shader.
The shadow follows the light direction, adjusting its position based on the sprite's location and screen center.

Usage: Duplicate a `TextureRect` node, assign this shader to the new one, and then adjust the `shadow_offset` to position the shadow. 
You must set the `screen_center` uniform from script using the viewport size, e.g.:
`shader_material.set_shader_parameter("screen_center", Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5))`

- Godot Engine Version: 4.4.1
- Shader Version: 1.1
- Repository: https://github.com/joanroig/godot-shaders
- License: MIT
**/

shader_type canvas_item;

// Color of the shadow (RGBA format, default: semi-transparent black).
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.3);

// Shadow scale factor: scales distance from center to shadow length
uniform float shadow_scale = 0.025;

// Minimum and maximum shadow length (in pixels)
uniform float shadow_min_length = 2.0;
uniform float shadow_max_length = 10.0;

// Center position of the screen (should be set from script, e.g. viewport_size * 0.5)
uniform vec2 screen_center = vec2(960.0, 540.0);

// A varying to store the sprite's rotation angle computed in the vertex shader.
varying float sprite_rotation;
varying vec2 screen_position;

// Function to rotate a 2D point by a given angle (in radians).
vec2 rotate_point(vec2 point, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(
        point.x * c - point.y * s,
        point.x * s + point.y * c
    );
}

void vertex() {
    // Calculate the sprite's rotation angle from the MODEL_MATRIX (rotation matrix).
    sprite_rotation = atan(MODEL_MATRIX[0][1], MODEL_MATRIX[0][0]);

    // Calculate the sprite's position in screen space.
    screen_position = (MODEL_MATRIX * vec4(VERTEX.xy, 0.0, 1.0)).xy;

    // Calculate the direction from the center to the sprite's position
    vec2 from_center = screen_position - screen_center;
    float dist = length(from_center);
    vec2 dir = dist > 0.0 ? normalize(from_center) : vec2(0.0, 1.0);

    // Clamp shadow length between minimum and maximum values, shadow_scale scales distance to shadow length
    float shadow_len = clamp(dist * shadow_scale, shadow_min_length, shadow_max_length);
    vec2 shadow_vec = dir * shadow_len;

    // Combine the calculated shadow and user offset, rotate with sprite
    VERTEX.xy += rotate_point(shadow_vec, -sprite_rotation);
}

void fragment() {
    // Sample the original texture to obtain the sprite's color.
    vec4 tex_color = texture(TEXTURE, UV);

    // Apply the shadow color by multiplying the sprite's texture color with the shadow color.
    COLOR = tex_color * shadow_color;
}
