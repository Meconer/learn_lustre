import lustre/attribute

pub fn container_styles() {
  [
    attribute.style("background", "#53027bff"),
    attribute.style("color", "#de9dffff"),
    attribute.style("min-height", "100vh"),
    attribute.style("display", "flex"),
    attribute.style("flex-direction", "column"),
    attribute.style("align-items", "center"),
    attribute.style("margin", "5px"),
    attribute.style("padding", "5px"),
  ]
}

pub fn canvas_styles() {
  [
    attribute.style("image-rendering", "pixelated"),
    attribute.style("width", "1080px"),
    attribute.style("height", "1080px"),
    attribute.style("border", "5px solid #de9dff"),
    attribute.style("background", "#000"),
    attribute.style("margin", "20px"),
  ]
}

pub fn button_styles() {
  [
    attribute.style("padding", "10px 20px"),
    attribute.style("font-size", "x-large"),
    attribute.style("cursor", "pointer"),
    attribute.style("background", "#53027b"),
    attribute.style("color", "#de9dff"),
    attribute.style("border", "3px solid #de9dff"),
    attribute.style("border-radius", "10px"),
    attribute.style("margin", "15px"),
  ]
}

pub fn textarea_styles() {
  [
    attribute.style("width", "500px"),
    attribute.style("height", "150px"),
    attribute.style("background", "#53027b"),
    attribute.style("color", "#de9dff"),
    attribute.style("font-family", "monospace"),
  ]
}
