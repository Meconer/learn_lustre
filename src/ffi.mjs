export function setTimeout(ms, callback) {
  window.setTimeout(() => {
    callback();
  }, ms);
}

export function render_pixels(canvasId, width, height, bitArray) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext("2d");

  // Gleam BitArrays have a 'buffer' property (Uint8Array)
  const imgData = new ImageData(
    new Uint8ClampedArray(bitArray.rawBuffer.buffer),
    width,
    height
  );

  ctx.putImageData(imgData, 0, 0);
}
