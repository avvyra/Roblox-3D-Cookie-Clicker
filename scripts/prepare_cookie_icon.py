"""Normalize the supplied transparent cookie artwork for Roblox UI (Pillow)."""
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parent.parent
source = root / "cookieclicker-ui" / "Codex Image Sep 5, 2026, 11_36_31 PM.png"
output = root / "cookieclicker-ui" / "processed" / "cookie-pop.png"
image = Image.open(source).convert("RGBA")
# Original already has an alpha background. Remove near-invisible alpha noise
# and make the almost-opaque interior fully opaque, retaining antialiased edges.
alpha = image.getchannel("A").point(lambda a: 0 if a < 8 else 255 if a >= 248 else a)
image.putalpha(alpha)
bounds = alpha.getbbox()
if bounds is None:
    raise ValueError("No visible cookie pixels")
image = image.crop(bounds)
image.thumbnail((480, 480), Image.Resampling.LANCZOS)
canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
canvas.alpha_composite(image, ((512 - image.width) // 2, (512 - image.height) // 2))
output.parent.mkdir(parents=True, exist_ok=True)
canvas.save(output, optimize=True)
print(f"Prepared {output.relative_to(root)}: 512x512 RGBA, transparent padding")
