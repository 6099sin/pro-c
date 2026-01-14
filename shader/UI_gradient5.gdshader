shader_type canvas_item;

// สีตรงกลาง และ สีที่ขอบสองข้าง
uniform vec4 color_center : source_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform vec4 color_edge : source_color = vec4(0.2, 0.2, 0.2, 1.0);

// การตั้งค่าขอบ (Border)
uniform vec4 border_color : source_color = vec4(1.0);
uniform float border_width : hint_range(0.0, 0.5) = 0.05;

// เลือกแกน: 0.0 = แนวนอน (Horizontal), 1.0 = แนวตั้ง (Vertical)
uniform float axis : hint_range(0.0, 1.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;
    float linear_dist;

    // 1. คำนวณระยะเส้นตรงจากจุดศูนย์กลาง (Mirror Linear Logic)
    if (axis == 0.0) {
        // วัดจากกึ่งกลางแกน X ออกไปซ้ายและขวา
        linear_dist = abs(uv.x - 0.5) * 2.0;
    } else {
        // วัดจากกึ่งกลางแกน Y ออกไปบนและล่าง
        linear_dist = abs(uv.y - 0.5) * 2.0;
    }

    // 2. ผสมสี Background ตามระยะเส้นตรง
    vec4 bg_color = mix(color_center, color_edge, clamp(linear_dist, 0.0, 1.0));

    // 3. ตรวจสอบพื้นที่ขอบ (Border)
    // อ้างอิงโครงสร้างจาก StyleBoxFlat
    bool is_border = (uv.x < border_width || uv.x > 1.0 - border_width ||
                      uv.y < border_width || uv.y > 1.0 - border_width);

    // 4. แสดงผล
    if (is_border) {
        COLOR = border_color;
    } else {
        COLOR = bg_color;
    }
}