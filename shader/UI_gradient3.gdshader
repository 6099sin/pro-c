shader_type canvas_item;

// สีตรงกลาง และ สีที่ขอบ
uniform vec4 color_center : source_color = vec4(0.0, 0.6, 0.8, 1.0);
uniform vec4 color_edge : source_color = vec4(0.0, 0.1, 0.2, 1.0);

// สีขอบ (Border)
uniform vec4 border_color : source_color = vec4(1.0);
uniform float border_width : hint_range(0.0, 0.5) = 0.05;

// เลือกโหมด: 0.0 = วงกลม (Radial), 1.0 = สี่เหลี่ยม (Box)
uniform float gradient_type : hint_range(0.0, 1.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;
    vec2 centered_uv = uv - vec2(0.5);
    float dist;

    // 1. คำนวณระยะห่าง (Distance Calculation)
    if (gradient_type == 0.0) {
        // แบบวงกลม (Radial)
        dist = length(centered_uv) * 2.0;
    } else {
        // แบบสี่เหลี่ยม (Box)
        dist = max(abs(centered_uv.x), abs(centered_uv.y)) * 2.0;
    }

    // 2. คำนวณสีพื้นหลัง (Background Gradient)
    vec4 bg_color = mix(color_center, color_edge, clamp(dist, 0.0, 1.0));

    // 3. คำนวณพื้นที่ขอบ (Border Logic)
    // ใช้สี่เหลี่ยมในการตัดขอบเสมอเพื่อให้ขนานกับตัว Panel
    bool is_border = (uv.x < border_width || uv.x > 1.0 - border_width || 
                      uv.y < border_width || uv.y > 1.0 - border_width);

    // 4. แสดงผล
    if (is_border) {
        COLOR = border_color;
    } else {
        COLOR = bg_color;
    }
}