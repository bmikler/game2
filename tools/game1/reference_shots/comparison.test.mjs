import assert from "node:assert/strict";
import { test } from "node:test";
import { compareFrames } from "./comparison.mjs";

const ROOMS = [
  { id: "left", rect: [0, 0, 64, 64] },
  { id: "right", rect: [64, 0, 64, 64] },
];

function frame(width = 128, height = 64, value = 100) {
  return { width, height, data: new Uint8Array(width * height * 4).fill(value) };
}

function paint(image, [x, y, width, height], value) {
  for (let row = y; row < y + height; row++) {
    for (let column = x; column < x + width; column++) {
      const at = (row * image.width + column) * 4;
      image.data[at] = value;
      image.data[at + 1] = value;
      image.data[at + 2] = value;
    }
  }
}

function differentRooms(result) {
  return result.rooms.filter((room) => room.different).map((room) => room.id);
}

test("a small bright detail is a difference", () => {
  const candidate = frame();
  paint(candidate, [12, 44, 2, 2], 255);
  assert.deepEqual(differentRooms(compareFrames(frame(), candidate, ROOMS)), ["left"]);
});

test("film grain is not a difference", () => {
  const grainy = frame();
  for (let at = 0; at < grainy.data.length; at += 4) {
    const offset = ((at * 2654435761) >>> 0) % 5 - 2;
    grainy.data[at] = 100 + offset;
    grainy.data[at + 1] = 100 + offset;
    grainy.data[at + 2] = 100 + offset;
  }
  assert.deepEqual(differentRooms(compareFrames(frame(), grainy, ROOMS)), []);
});

test("a slight colour shift across a whole room is a difference", () => {
  const shifted = frame();
  paint(shifted, [0, 0, 64, 64], 108);
  assert.deepEqual(differentRooms(compareFrames(frame(), shifted, ROOMS)), ["left"]);
});

test("a texture moved by one pixel is a difference", () => {
  const stripes = (offset) => {
    const image = frame();
    for (let x = 0; x < 128; x++) {
      if ((x + offset) % 2 === 0) paint(image, [x, 0, 1, 64], 140);
    }
    return image;
  };
  assert.deepEqual(differentRooms(compareFrames(stripes(0), stripes(1), ROOMS)), ["left", "right"]);
});

test("identical frames show no differences", () => {
  assert.deepEqual(differentRooms(compareFrames(frame(), frame(), ROOMS)), []);
});

test("a changed object is reported only for the room it stands in", () => {
  const candidate = frame();
  paint(candidate, [80, 16, 24, 24], 180);
  assert.deepEqual(differentRooms(compareFrames(frame(), candidate, ROOMS)), ["right"]);
});
