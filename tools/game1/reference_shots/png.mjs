// Minimal PNG reader and writer for frames saved by Godot: 8-bit RGB or RGBA, not interlaced.
// Images are { width, height, data } with data as RGBA bytes.
import { crc32, deflateSync, inflateSync } from "node:zlib";

const SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const COLOR_RGB = 2;
const COLOR_RGBA = 6;

export function decodePng(file) {
  if (!file.subarray(0, 8).equals(SIGNATURE)) throw new Error("not a PNG file");
  let width = 0;
  let height = 0;
  let channels = 0;
  const compressed = [];
  for (let at = 8; at < file.length; ) {
    const length = file.readUInt32BE(at);
    const type = file.toString("latin1", at + 4, at + 8);
    const body = file.subarray(at + 8, at + 8 + length);
    if (type === "IHDR") {
      width = body.readUInt32BE(0);
      height = body.readUInt32BE(4);
      const [depth, color, , , interlace] = body.subarray(8);
      if (depth !== 8 || (color !== COLOR_RGB && color !== COLOR_RGBA) || interlace !== 0) {
        throw new Error(`unsupported PNG: depth ${depth}, color ${color}, interlace ${interlace}`);
      }
      channels = color === COLOR_RGBA ? 4 : 3;
    } else if (type === "IDAT") {
      compressed.push(body);
    }
    at += length + 12;
  }
  const raw = unfilter(inflateSync(Buffer.concat(compressed)), width, height, channels);
  const data = new Uint8Array(width * height * 4);
  for (let pixel = 0; pixel < width * height; pixel++) {
    for (let channel = 0; channel < channels; channel++) {
      data[pixel * 4 + channel] = raw[pixel * channels + channel];
    }
    if (channels === 3) data[pixel * 4 + 3] = 255;
  }
  return { width, height, data };
}

export function encodePng({ width, height, data }) {
  const stride = width * 4;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y++) {
    raw.set(data.subarray(y * stride, (y + 1) * stride), y * (stride + 1) + 1);
  }
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header[8] = 8;
  header[9] = COLOR_RGBA;
  return Buffer.concat([
    SIGNATURE,
    chunk("IHDR", header),
    chunk("IDAT", deflateSync(raw)),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

function unfilter(filtered, width, height, channels) {
  const stride = width * channels;
  const out = new Uint8Array(stride * height);
  for (let y = 0; y < height; y++) {
    const filter = filtered[y * (stride + 1)];
    const source = y * (stride + 1) + 1;
    const target = y * stride;
    for (let x = 0; x < stride; x++) {
      const left = x >= channels ? out[target + x - channels] : 0;
      const up = y > 0 ? out[target + x - stride] : 0;
      const upLeft = y > 0 && x >= channels ? out[target + x - stride - channels] : 0;
      out[target + x] = filtered[source + x] + predict(filter, left, up, upLeft);
    }
  }
  return out;
}

function predict(filter, left, up, upLeft) {
  switch (filter) {
    case 0:
      return 0;
    case 1:
      return left;
    case 2:
      return up;
    case 3:
      return (left + up) >> 1;
    case 4:
      return paeth(left, up, upLeft);
    default:
      throw new Error(`unknown PNG filter ${filter}`);
  }
}

function paeth(left, up, upLeft) {
  const estimate = left + up - upLeft;
  const toLeft = Math.abs(estimate - left);
  const toUp = Math.abs(estimate - up);
  const toUpLeft = Math.abs(estimate - upLeft);
  if (toLeft <= toUp && toLeft <= toUpLeft) return left;
  return toUp <= toUpLeft ? up : upLeft;
}

function chunk(type, body) {
  const typed = Buffer.concat([Buffer.from(type, "latin1"), body]);
  const out = Buffer.alloc(body.length + 12);
  out.writeUInt32BE(body.length, 0);
  typed.copy(out, 4);
  out.writeUInt32BE(crc32(typed), body.length + 8);
  return out;
}
