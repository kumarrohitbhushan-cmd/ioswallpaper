const { createCanvas } = require('@napi-rs/canvas');

module.exports = async (req, res) => {
  // ─── Config ───
  const ACCENT = '#34D399';
  const COLUMNS = 15;
  const ROWS = 25;
  const BG = '#0A0A0A';
  const W = 1206;
  const H = 2622;

  // ─── Day calc ───
  const now = new Date();
  const year = now.getFullYear();
  const start = new Date(year, 0, 0);
  const currentDay = Math.floor((now - start) / 86400000);
  const isLeap = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
  const totalDays = isLeap ? 366 : 365;

  // ─── Canvas ───
  const canvas = createCanvas(W, H);
  const ctx = canvas.getContext('2d');
  const scale = W / 1179;

  function hex2rgba(hex, a) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r},${g},${b},${a})`;
  }

  function roundRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  // Background
  ctx.fillStyle = BG;
  ctx.fillRect(0, 0, W, H);

  const cr = 17 * scale;
  const hGap = cr * 2.6;
  const vGap = cr * 2.35;
  const gridW = (COLUMNS - 1) * hGap;
  const gridH = (ROWS - 1) * vGap;
  const startX = (W - gridW) / 2;
  const startY = (H - gridH) / 2 + 120 * scale;

  // Year label
  ctx.save();
  ctx.font = `200 ${100 * scale}px sans-serif`;
  ctx.fillStyle = 'rgba(255,255,255,0.18)';
  ctx.textAlign = 'center';
  ctx.fillText(String(year), W / 2, startY - 120 * scale);

  // Day counter
  ctx.font = `400 ${36 * scale}px monospace`;
  ctx.fillStyle = hex2rgba(ACCENT, 0.5);
  ctx.fillText(`DAY ${currentDay} OF ${totalDays}`, W / 2, startY - 60 * scale);
  ctx.restore();

  // Circles
  for (let row = 0; row < ROWS; row++) {
    for (let col = 0; col < COLUMNS; col++) {
      const d = row * COLUMNS + col + 1;
      if (d > totalDays) continue;
      const cx = startX + col * hGap;
      const cy = startY + row * vGap;

      if (d < currentDay) {
        ctx.beginPath();
        ctx.arc(cx, cy, cr, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(255,255,255,0.82)';
        ctx.fill();
      } else if (d === currentDay) {
        // Glow
        const g = ctx.createRadialGradient(cx, cy, cr * 0.5, cx, cy, cr * 3);
        g.addColorStop(0, hex2rgba(ACCENT, 0.3));
        g.addColorStop(1, hex2rgba(ACCENT, 0));
        ctx.beginPath();
        ctx.arc(cx, cy, cr * 3, 0, Math.PI * 2);
        ctx.fillStyle = g;
        ctx.fill();

        // Dot
        ctx.beginPath();
        ctx.arc(cx, cy, cr, 0, Math.PI * 2);
        ctx.fillStyle = ACCENT;
        ctx.shadowColor = hex2rgba(ACCENT, 0.6);
        ctx.shadowBlur = 14 * scale;
        ctx.fill();
        ctx.shadowColor = 'transparent';
        ctx.shadowBlur = 0;
      } else {
        ctx.beginPath();
        ctx.arc(cx, cy, cr, 0, Math.PI * 2);
        ctx.strokeStyle = 'rgba(255,255,255,0.08)';
        ctx.lineWidth = Math.max(1, 1.2 * scale);
        ctx.stroke();
      }
    }
  }

  // Progress bar
  const barY = startY + gridH + 60 * scale;
  const barW = gridW + hGap * 0.4;
  const barH = 3 * scale;
  const barX = (W - barW) / 2;
  const progress = Math.min(currentDay, totalDays) / totalDays;

  ctx.fillStyle = 'rgba(255,255,255,0.05)';
  roundRect(ctx, barX, barY, barW, barH, barH / 2);
  ctx.fill();

  ctx.fillStyle = hex2rgba(ACCENT, 0.4);
  roundRect(ctx, barX, barY, barW * progress, barH, barH / 2);
  ctx.fill();

  // Percentage
  const pct = Math.round(currentDay / totalDays * 100);
  ctx.font = `300 ${28 * scale}px monospace`;
  ctx.fillStyle = 'rgba(255,255,255,0.2)';
  ctx.textAlign = 'center';
  ctx.fillText(`${pct}% complete`, W / 2, barY + 40 * scale);

  // ─── Return PNG ───
  const buffer = canvas.toBuffer('image/png');
  res.setHeader('Content-Type', 'image/png');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  res.send(buffer);
};
