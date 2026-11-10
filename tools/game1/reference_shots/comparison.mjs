// Compares two frames per room. Averaging over small blocks hides what differs between any two
// runs of the same scene (film grain, dust) and keeps what the eye sees as a difference. README.md
// records how the limits were measured.

const BLOCK_SIZE = 8;
// Means per channel in a block, out of 255. Shift is signed and catches a change of light or colour.
// Mismatch is absolute and catches a texture moved by a pixel, whose signed differences cancel out.
const SHIFT_LIMIT = 6;
const MISMATCH_LIMIT = 8;
const DIFFERENCE_GAIN = 8;
const MARK_RED = 170;

export function compareFrames(reference, candidate, rooms) {
  const grid = blockDifferences(reference, candidate);
  const marked = new Uint8Array(grid.shift.length);
  const results = rooms.map((room) => {
    const differentBlocks = markDifferentBlocks(grid, room, marked);
    return { id: room.id, differentBlocks, different: differentBlocks > 0 };
  });
  return { grid, marked, rooms: results };
}

// Black where nothing changed, amplified grey for any change, red over blocks past the threshold,
// a yellow outline around each room with a difference. Rooms left out of `rooms` stay black.
export function renderDifference(reference, candidate, comparison, rooms) {
  const { width, height } = reference;
  const data = new Uint8Array(width * height * 4);
  const { grid, marked } = comparison;
  for (const { rect } of rooms) {
    forEachPixel(rect, width, height, (x, y) => {
      const at = (y * width + x) * 4;
      let change = 0;
      for (let channel = 0; channel < 3; channel++) {
        change = Math.max(change, Math.abs(candidate.data[at + channel] - reference.data[at + channel]));
      }
      const grey = Math.min(255, change * DIFFERENCE_GAIN);
      const block = Math.floor(y / BLOCK_SIZE) * grid.columns + Math.floor(x / BLOCK_SIZE);
      data[at] = marked[block] ? Math.max(grey, MARK_RED) : grey;
      data[at + 1] = grey;
      data[at + 2] = grey;
    });
  }
  for (const room of comparison.rooms) {
    if (room.different) outline(data, width, height, rooms.find(({ id }) => id === room.id).rect);
  }
  for (let at = 3; at < data.length; at += 4) data[at] = 255;
  return { width, height, data };
}

function forEachPixel([x, y, rectWidth, rectHeight], width, height, visit) {
  const right = Math.min(x + rectWidth, width);
  const bottom = Math.min(y + rectHeight, height);
  for (let row = Math.max(y, 0); row < bottom; row++) {
    for (let column = Math.max(x, 0); column < right; column++) visit(column, row);
  }
}

function outline(data, width, height, rect) {
  const [x, y, rectWidth, rectHeight] = rect;
  forEachPixel(rect, width, height, (column, row) => {
    if (column !== x && column !== x + rectWidth - 1 && row !== y && row !== y + rectHeight - 1) return;
    const at = (row * width + column) * 4;
    data[at] = 255;
    data[at + 1] = 220;
    data[at + 2] = 0;
  });
}

function blockDifferences(reference, candidate) {
  const columns = Math.ceil(reference.width / BLOCK_SIZE);
  const rows = Math.ceil(reference.height / BLOCK_SIZE);
  const signedSums = new Float64Array(columns * rows * 3);
  const absoluteSums = new Float64Array(columns * rows * 3);
  const counts = new Uint32Array(columns * rows);
  for (let y = 0; y < reference.height; y++) {
    const row = Math.floor(y / BLOCK_SIZE);
    for (let x = 0; x < reference.width; x++) {
      const block = row * columns + Math.floor(x / BLOCK_SIZE);
      const at = (y * reference.width + x) * 4;
      counts[block]++;
      for (let channel = 0; channel < 3; channel++) {
        const difference = candidate.data[at + channel] - reference.data[at + channel];
        signedSums[block * 3 + channel] += difference;
        absoluteSums[block * 3 + channel] += Math.abs(difference);
      }
    }
  }
  const shift = new Float64Array(columns * rows);
  const mismatch = new Float64Array(columns * rows);
  for (let block = 0; block < shift.length; block++) {
    const signed = signedSums.subarray(block * 3, block * 3 + 3);
    const absolute = absoluteSums.subarray(block * 3, block * 3 + 3);
    shift[block] = Math.max(...signed.map(Math.abs)) / counts[block];
    mismatch[block] = Math.max(...absolute) / counts[block];
  }
  return { columns, rows, shift, mismatch };
}

// A block belongs to a room when its centre lies inside the room's rectangle.
function markDifferentBlocks(grid, room, marked) {
  const [x, y, width, height] = room.rect;
  let count = 0;
  for (let row = 0; row < grid.rows; row++) {
    const centerY = (row + 0.5) * BLOCK_SIZE;
    if (centerY < y || centerY >= y + height) continue;
    for (let column = 0; column < grid.columns; column++) {
      const centerX = (column + 0.5) * BLOCK_SIZE;
      if (centerX < x || centerX >= x + width) continue;
      const block = row * grid.columns + column;
      if (grid.shift[block] > SHIFT_LIMIT || grid.mismatch[block] > MISMATCH_LIMIT) {
        marked[block] = 1;
        count++;
      }
    }
  }
  return count;
}
