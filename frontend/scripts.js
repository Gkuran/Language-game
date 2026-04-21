const simulationButton = document.querySelector("[data-simulation-toggle]");
const simulationCanvas = document.querySelector("[data-simulation-canvas]");

const CANVAS_SIZE = 480;
const GRID_SIZE = 40;
const FRAME_DURATION = 180;
const CELL_SIZE = CANVAS_SIZE / GRID_SIZE;
const CSV_PATH = "./data/automata-simulation.csv";

function parseSimulationCsv(csvText) {
  const lines = csvText.trim().split(/\r?\n/);
  const rows = lines.slice(1);
  const frames = new Map();

  for (const row of rows) {
    if (!row.trim()) {
      continue;
    }

    const [frameValue, xValue, yValue, stateValue] = row.split(",");
    const frame = Number.parseInt(frameValue, 10);
    const x = Number.parseInt(xValue, 10);
    const y = Number.parseInt(yValue, 10);
    const state = Number.parseInt(stateValue, 10);

    if (!frames.has(frame)) {
      frames.set(frame, []);
    }

    frames.get(frame).push({ x, y, state });
  }

  return Array.from(frames.entries())
    .sort(([left], [right]) => left - right)
    .map(([, cells]) => cells);
}

async function loadSimulationFrames(path) {
  const response = await fetch(path);

  if (!response.ok) {
    throw new Error(
      `Nao foi possivel carregar o arquivo CSV: ${response.status}`,
    );
  }

  const csvText = await response.text();
  return parseSimulationCsv(csvText);
}

function drawBackground(context) {
  context.fillStyle = "#050505";
  context.fillRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
}

function drawFrame(context, frameCells) {
  drawBackground(context);

  for (const cell of frameCells) {
    if (cell.state !== 1) {
      continue;
    }

    context.fillStyle = "#3cac45";
    context.fillRect(
      cell.x * CELL_SIZE,
      cell.y * CELL_SIZE,
      CELL_SIZE,
      CELL_SIZE,
    );
  }
}

function createSimulationPlayer(context, frames) {
  let animationFrameId = null;
  let currentFrameIndex = 0;
  let previousTimestamp = 0;
  let isPlaying = false;

  function renderCurrentFrame() {
    drawFrame(context, frames[currentFrameIndex]);
  }

  function tick(timestamp) {
    if (!isPlaying) {
      return;
    }

    if (!previousTimestamp) {
      previousTimestamp = timestamp;
    }

    const elapsed = timestamp - previousTimestamp;

    if (elapsed >= FRAME_DURATION) {
      currentFrameIndex = (currentFrameIndex + 1) % frames.length;
      previousTimestamp = timestamp;
      renderCurrentFrame();
    }

    animationFrameId = window.requestAnimationFrame(tick);
  }

  function start() {
    if (isPlaying) {
      return;
    }

    isPlaying = true;
    previousTimestamp = 0;
    animationFrameId = window.requestAnimationFrame(tick);
  }

  function reset() {
    isPlaying = false;

    if (animationFrameId) {
      window.cancelAnimationFrame(animationFrameId);
    }

    animationFrameId = null;
    previousTimestamp = 0;
    currentFrameIndex = 0;
    renderCurrentFrame();
  }

  renderCurrentFrame();

  return { start, reset };
}

async function setupSimulation() {
  if (!simulationCanvas || !simulationButton) {
    return;
  }

  const context = simulationCanvas.getContext("2d");

  if (!context) {
    return;
  }

  try {
    const frames = await loadSimulationFrames(CSV_PATH);

    if (!frames.length) {
      throw new Error("O CSV nao contem frames validos.");
    }

    const player = createSimulationPlayer(context, frames);

    simulationButton.addEventListener("click", () => {
      const isStarting =
        simulationButton.textContent.trim() === "Start Simulation";

      simulationButton.textContent = isStarting
        ? "Reset Simulation"
        : "Start Simulation";

      if (isStarting) {
        player.start();
        return;
      }

      player.reset();
    });
  } catch (error) {
    drawBackground(context);
    console.error(error);
  }
}

setupSimulation();
