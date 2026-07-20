#!/usr/bin/env python3
"""智贷计算器 — 应用图标与 Play 素材生成器（PIL）。"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = "/Users/mac/Documents/Kimi/Workspaces/LoanCalculator/loan_calculator_app"
ICON_DIR = os.path.join(ROOT, "assets", "icon")
STORE_DIR = os.path.join(ROOT, "store_assets")
FONT_BOLD = os.path.join(ROOT, "assets", "fonts", "NotoSansSC-Bold.ttf")
FONT_REG = os.path.join(ROOT, "assets", "fonts", "NotoSansSC-Regular.ttf")
os.makedirs(ICON_DIR, exist_ok=True)
os.makedirs(STORE_DIR, exist_ok=True)

# 主题色：深蓝渐变 + 白
TOP = (22, 48, 92)      # #16305C
BOTTOM = (44, 93, 168)  # #2C5DA8
WHITE = (255, 255, 255)
DISPLAY_BG = (222, 234, 250)  # 显示屏浅蓝
INK = (27, 58, 107)     # 显示屏上 ¥ 的深蓝
BTN = (27, 58, 107)     # 按钮深蓝


def gradient(size):
    """对角线深蓝渐变。"""
    w, h = size
    base = Image.new("RGB", size)
    px = base.load()
    for y in range(h):
        for x in range(0, w, 4):  # 每 4px 采样再放大，提速
            t = (x / w + y / h) / 2
            c = tuple(int(TOP[i] + (BOTTOM[i] - TOP[i]) * t) for i in range(3))
            for dx in range(4):
                if x + dx < w:
                    px[x + dx, y] = c
    return base


def draw_calculator(draw, cx, cy, s, body_color=WHITE, detail_color=INK):
    """以 (cx,cy) 为中心绘制边长 s 的计算器图形。

    s = 整体外框宽度。display 占上部，按钮 3x3。
    """
    body_w = s * 0.78
    body_h = s * 0.98
    x0, y0 = cx - body_w / 2, cy - body_h / 2
    r = s * 0.14
    # 机身
    draw.rounded_rectangle([x0, y0, x0 + body_w, y0 + body_h], radius=r, fill=body_color)
    # 显示屏
    pad = s * 0.075
    disp_h = s * 0.26
    draw.rounded_rectangle(
        [x0 + pad, y0 + pad, x0 + body_w - pad, y0 + pad + disp_h],
        radius=s * 0.06,
        fill=DISPLAY_BG,
    )
    # 屏内 ¥（手绘笔画，避免字体缺字形）
    yen_cx = x0 + body_w / 2
    yen_cy = y0 + pad + disp_h / 2
    u = disp_h * 0.30  # 半高基准
    w_line = max(2, int(disp_h * 0.075))
    # 上半两斜笔
    draw.line([yen_cx - u * 0.85, yen_cy - u, yen_cx, yen_cy - u * 0.1],
              fill=detail_color, width=w_line)
    draw.line([yen_cx + u * 0.85, yen_cy - u, yen_cx, yen_cy - u * 0.1],
              fill=detail_color, width=w_line)
    # 竖笔
    draw.line([yen_cx, yen_cy - u * 0.1, yen_cx, yen_cy + u],
              fill=detail_color, width=w_line)
    # 两横
    draw.line([yen_cx - u * 0.62, yen_cy + u * 0.18, yen_cx + u * 0.62, yen_cy + u * 0.18],
              fill=detail_color, width=w_line)
    draw.line([yen_cx - u * 0.62, yen_cy + u * 0.52, yen_cx + u * 0.62, yen_cy + u * 0.52],
              fill=detail_color, width=w_line)
    # 按钮 3x3
    grid_top = y0 + pad * 2 + disp_h
    grid_bot = y0 + body_h - pad
    grid_h = grid_bot - grid_top
    bw = body_w - pad * 2
    btn = min(bw / 3, grid_h / 3) * 0.62
    for row in range(3):
        for col in range(3):
            bx = x0 + pad + bw * (col + 0.5) / 3
            by = grid_top + grid_h * (row + 0.5) / 3
            if row == 2 and col == 2:  # 右下角等号按钮用主题色长条感
                draw.rounded_rectangle(
                    [bx - btn / 2, by - btn / 2, bx + btn / 2, by + btn / 2],
                    radius=btn * 0.32,
                    fill=(240, 168, 64),  # 点缀金橙
                )
                feq = ImageFont.truetype(FONT_BOLD, int(btn * 0.58))
                draw.text((bx, by), "=", font=feq, fill=WHITE, anchor="mm")
            else:
                draw.rounded_rectangle(
                    [bx - btn / 2, by - btn / 2, bx + btn / 2, by + btn / 2],
                    radius=btn * 0.32,
                    fill=detail_color,
                )


def rounded_mask(img, radius):
    mask = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, img.size[0], img.size[1]], radius=radius, fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def main():
    S = 1024
    bg = gradient((S, S)).convert("RGBA")

    # 1) 母图（全幅，供 flutter_launcher_icons；iOS 会自动套圆角蒙版）
    master = bg.copy()
    d = ImageDraw.Draw(master)
    draw_calculator(d, S / 2, S / 2, S * 0.62)
    master.convert("RGB").save(os.path.join(ICON_DIR, "app_icon.png"))
    print("app_icon.png (1024 母图, 全幅)")

    # 2) Android adaptive foreground：透明底，图形缩到安全区（≈58%）
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(fg)
    draw_calculator(d, S / 2, S / 2, S * 0.40)
    fg.save(os.path.join(ICON_DIR, "adaptive_fg.png"))
    print("adaptive_fg.png (1024 前景, 透明)")

    # 3) Android adaptive background：纯渐变
    bg.convert("RGB").save(os.path.join(ICON_DIR, "adaptive_bg.png"))
    print("adaptive_bg.png (1024 背景)")

    # 4) Play Console 512 图标（全幅，Play 自行裁圆角）
    icon512 = master.resize((512, 512), Image.LANCZOS).convert("RGB")
    icon512.save(os.path.join(STORE_DIR, "icon_512.png"))
    print("store_assets/icon_512.png")

    # 5) Play 功能横幅 1024x500
    W, H = 1024, 500
    banner = gradient((W, H)).convert("RGBA")
    # 左侧圆角图标
    icon_r = rounded_mask(master.resize((300, 300), Image.LANCZOS), 64)
    banner.paste(icon_r, (84, 100), icon_r)
    bd = ImageDraw.Draw(banner)
    ft = ImageFont.truetype(FONT_BOLD, 96)
    fs = ImageFont.truetype(FONT_REG, 44)
    bd.text((440, 168), "智贷计算器", font=ft, fill=WHITE, anchor="lm")
    bd.text((442, 300), "月供利息，一算便知", font=fs, fill=(198, 216, 240), anchor="lm")
    banner.convert("RGB").save(os.path.join(STORE_DIR, "feature_graphic_1024x500.png"))
    print("store_assets/feature_graphic_1024x500.png")


if __name__ == "__main__":
    main()
