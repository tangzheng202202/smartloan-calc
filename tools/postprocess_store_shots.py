#!/usr/bin/env python3
"""商店截图后处理：分发原图、生成 android 裁剪版、生成 caption 营销版。"""
import os
import shutil
from PIL import Image, ImageDraw, ImageFont

WS = "/Users/mac/Documents/Kimi/Workspaces/LoanCalculator"
RAW = "/tmp/store_shots"
DST = os.path.join(WS, "loan_calculator_app/store_assets/screenshots_store")
NOTO_BOLD = os.path.join(WS, "loan_calculator_app/assets/fonts/NotoSansSC-Bold.ttf")

BAND_LIGHT = (27, 58, 107)   # #1B3A6B
BAND_DARK = (46, 93, 163)    # #2E5FA3
WHITE = (255, 255, 255)

CAPTIONS = {
    "01_calculator": "月供利息，一算便知",
    "02_charts": "本金利息，一目了然",
    "03_schedule": "360 期还款计划，尽在掌握",
    "04_prepayment": "提前还款，省多少一眼看懂",
    "05_settings": "深色模式，护眼随行",
}

# iPhone 17 Pro Max 截图 1320x2868：状态栏≈170px，底部安全区下沿 2810
ANDROID_CROP = (0, 170, 1320, 2810)   # → 1320x2640
ANDROID_SIZE = (1080, 2160)           # 严格 2:1


def load_font(size):
    """优先系统 PingFang SC，失败退回项目内 NotoSansSC-Bold。"""
    pf = "/System/Library/Fonts/PingFang.ttc"
    if os.path.exists(pf):
        for idx in range(8):
            try:
                f = ImageFont.truetype(pf, size, index=idx)
                name = " ".join(f.getname())
                if "PingFang" in name and ("Medium" in name or "Semibold" in name):
                    return f
            except Exception:
                break
        try:
            return ImageFont.truetype(pf, size, index=0)
        except Exception:
            pass
    return ImageFont.truetype(NOTO_BOLD, size)


def make_caption(src, dst, dark):
    """letterbox 营销版：画布=原尺寸，顶部文案带，截图等比缩放居中。"""
    im = Image.open(src).convert("RGB")
    w, h = im.size
    cap_h = round(h * 0.12)
    band = BAND_DARK if dark else BAND_LIGHT
    canvas = Image.new("RGB", (w, h), band)
    scale = (h - cap_h) / h
    shot = im.resize((round(w * scale), round(h * scale)), Image.LANCZOS)
    canvas.paste(shot, ((w - shot.size[0]) // 2, cap_h))
    d = ImageDraw.Draw(canvas)
    page = os.path.basename(src).replace(".png", "")
    font = load_font(round(cap_h * 0.30))
    d.text((w / 2, cap_h / 2), CAPTIONS[page], font=font, fill=WHITE, anchor="mm")
    canvas.save(dst)


def main():
    combos = [("iphone6.9", "iphone6.9"), ("ipad13", "ipad13")]
    for src_combo, dst_combo in combos:
        for appear in ("light", "dark"):
            outdir = os.path.join(DST, dst_combo, appear)
            os.makedirs(outdir, exist_ok=True)
            for page in CAPTIONS:
                src = f"{RAW}/{src_combo}_{appear}/{page}.png"
                plain = os.path.join(outdir, f"{page}.png")
                shutil.copy2(src, plain)
                make_caption(src, os.path.join(outdir, f"{page}_caption.png"),
                             dark=(appear == "dark"))
                print("OK", dst_combo, appear, page)

    # android：由 iPhone 原图裁状态栏/Home 指示区后缩放到 1080x2160
    for appear in ("light", "dark"):
        outdir = os.path.join(DST, "android", appear)
        os.makedirs(outdir, exist_ok=True)
        for page in CAPTIONS:
            src = f"{RAW}/iphone6.9_{appear}/{page}.png"
            im = Image.open(src).convert("RGB").crop(ANDROID_CROP)
            im = im.resize(ANDROID_SIZE, Image.LANCZOS)
            plain = os.path.join(outdir, f"{page}.png")
            im.save(plain)
            make_caption(plain, os.path.join(outdir, f"{page}_caption.png"),
                         dark=(appear == "dark"))
            print("OK android", appear, page)


if __name__ == "__main__":
    main()
