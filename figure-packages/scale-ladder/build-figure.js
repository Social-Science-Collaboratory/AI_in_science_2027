/*
 * Builds figures/scale-ladder-figure.html — the HTML twin of R/scale-ladder.R.
 *
 * Same encoding: one dot = one credited co-author, each report drawn as a
 * near-square block so block area is proportional to the author count.
 *
 * The only trick worth knowing: a block is NOT thousands of elements. It's one
 * div whose background is a tiled radial-gradient — a single dot repeated every
 * DOT_PITCH pixels. Size the div to (side x rows) dots and you get the grid for
 * free. A second div holds the leftover partial row.
 *
 * Run with: node build-figure.js   (or paste into any JS console)
 */

const LAB_COLOURS = {
  OpenAI:        "#d55e00", // vermillion
  Google:        "#0072b2", // blue
  Meta:          "#009e73", // green
  "Open-weight": "#cc79a7", // pink
};

const DOT_PITCH  = 3;   // px between dot centres
const DOT_RADIUS = 0.8; // px
const BLOCK_GAP  = 18;  // px between blocks
const MIN_LABEL  = 66;  // px — keeps short rules as wide as their text

// model, date shown, co-authors, lab
const REPORTS = [
  ["Transformer",  "2017",     8,    "Google"],
  ["GPT-1",        "2018",     4,    "OpenAI"],
  ["GPT-2",        "2019",     6,    "OpenAI"],
  ["GPT-3",        "2020",     31,   "OpenAI"],
  ["PaLM",         "2022",     67,   "Google"],
  ["LLaMA",        "Feb 2023", 14,   "Meta"],
  ["GPT-4",        "Mar 2023", 280,  "OpenAI"],
  ["Llama 2",      "Jul 2023", 68,   "Meta"],
  ["Gemini 1.0",   "Dec 2023", 1350, "Google"],
  ["Gemini 1.5",   "Mar 2024", 671,  "Google"],
  ["Llama 3",      "Jul 2024", 559,  "Meta"],
  ["DeepSeek-V3",  "Dec 2024", 200,  "Open-weight"],
  ["Qwen3",        "May 2025", 60,   "Open-weight"],
  ["Kimi K2",      "Jul 2025", 199,  "Open-weight"],
  ["Gemini 2.5",   "Jul 2025", 3435, "Google"],
  ["GPT-5",        "Dec 2025", 485,  "OpenAI"],
];

// One tile of the dot grid, in `colour`.
function dotGrid(colour) {
  return `background-image:radial-gradient(circle at ${DOT_PITCH / 2}px ${DOT_PITCH / 2}px,` +
         `${colour} ${DOT_RADIUS}px,transparent ${DOT_RADIUS + 0.1}px);` +
         `background-size:${DOT_PITCH}px ${DOT_PITCH}px`;
}

// One report: the dot block, its rule, its count, its name.
function column(model, date, count, lab) {
  const colour   = LAB_COLOURS[lab];
  const side     = Math.ceil(Math.sqrt(count)); // dots per row
  const fullRows = Math.floor(count / side);
  const leftover = count % side;

  const fullBlock = fullRows
    ? `<div style="width:${side * DOT_PITCH}px;height:${fullRows * DOT_PITCH}px;${dotGrid(colour)}"></div>`
    : "";
  const partialRow = leftover
    ? `<div style="width:${leftover * DOT_PITCH}px;height:${DOT_PITCH}px;${dotGrid(colour)}"></div>`
    : "";

  const labelWidth = Math.max(side * DOT_PITCH, MIN_LABEL);

  return `<div style="display:flex;flex-direction:column;align-items:flex-start;gap:10px">
  <div style="display:flex;flex-direction:column;align-items:flex-start">${fullBlock}${partialRow}</div>
  <div style="width:${labelWidth}px;border-top:1px solid ${colour};padding-top:7px">
    <div style="font:500 11.5px/1.3 'IBM Plex Mono',monospace;color:${colour}">${count.toLocaleString("en-US")}</div>
    <div style="font:400 10.5px/1.35 'IBM Plex Sans',sans-serif;color:#8c8c8c">${model}<br>${date}</div>
  </div>
</div>`;
}

const columns = REPORTS.map(r => column(...r)).join("\n");

const legend = Object.entries(LAB_COLOURS).map(([lab, colour]) =>
  `<span style="display:flex;align-items:center;gap:7px">` +
  `<span style="width:9px;height:9px;border-radius:50%;background:${colour}"></span>` +
  `${lab === "Open-weight" ? "Chinese open-weight labs" : lab}</span>`
).join("");

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Co-authors on flagship model reports</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
body { margin: 0; background: #fff; font-family: 'IBM Plex Sans', system-ui, sans-serif; }
a { color: #8a5a3c; }
a:hover { color: #d55e00; }
</style>
</head>
<body>
<div id="figure" style="width:1560px;padding:34px 40px 28px;background:#fff">
  <div style="display:flex;gap:${BLOCK_GAP}px;align-items:flex-end">
${columns}
  </div>
  <div style="margin-top:30px;display:flex;gap:22px;font:400 11px/1 'IBM Plex Sans',sans-serif;color:#5c574e">${legend}</div>
</div>
</body>
</html>`;

if (typeof module !== "undefined") module.exports = { html, REPORTS, LAB_COLOURS };
