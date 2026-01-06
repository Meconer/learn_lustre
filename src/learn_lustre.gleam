import day4
import gleam/bit_array
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import paint as p
import styles

pub fn main() {
  let app = lustre.application(init, update, view)
  lustre.start(app, "#app", get_grid(""))
}

// --- 1. MODEL ---
// This holds all the data for your app
type Model {
  Model(
    input_text: String,
    width: Int,
    height: Int,
    grid: dict.Dict(#(Int, Int), String),
    initial_grid: dict.Dict(#(Int, Int), String),
    count: Int,
    is_running: Bool,
  )
}

pub fn get_grid(input: String) -> #(Int, Int, dict.Dict(#(Int, Int), String)) {
  let input = input |> string.split("\n")
  let height = list.length(input)
  let first_line = list.first(input) |> result.unwrap("")
  let width = string.length(first_line)
  let #(_, grid) =
    list.fold(input, #(#(0, 0), dict.new()), fn(acc, str) {
      let cols = string.to_graphemes(str)
      let #(_, col_dict) =
        list.fold(cols, acc, fn(inn_acc, el) {
          let #(#(row, col), mtx_dict) = inn_acc
          #(#(row, col + 1), dict.insert(mtx_dict, #(row, col), el))
        })
      let #(#(row, _col), mtx_dict) = acc
      #(#(row + 1, 0), dict.merge(mtx_dict, col_dict))
    })
  #(height, width, grid)
}

fn init(
  initial_data: #(Int, Int, dict.Dict(#(Int, Int), String)),
) -> #(Model, effect.Effect(Msg)) {
  let #(height, width, grid) = initial_data
  let initial_model = Model("", width, height, grid, grid, 0, False)
  #(initial_model, effect.none())
}

// --- 2. MSGS ---
// These are the ONLY things that can happen in your app
pub type Msg {
  UserClickedStart
  Tick
  UserClickedReset
  UserUpdatedInput(String)
  UserClickedSubmitData
}

// --- 3. UPDATE ---
// This is your logic. It's a pure function! 
// It takes the current state + an event, and returns the NEW state.
fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    UserClickedStart -> {
      let #(height, width, grid) = get_grid(model.input_text)
      #(
        Model(
          ..model,
          height: height,
          width: width,
          grid: grid,
          initial_grid: grid,
          is_running: True,
        ),
        execute_tick(),
      )
    }
    Tick -> {
      case model.is_running {
        True -> {
          let #(did_remove, next_grid, remove_count) =
            day4.remove_step(model.width, model.height, model.grid)
          let next_state =
            Model(
              ..model,
              grid: next_grid,
              count: model.count + remove_count,
              is_running: did_remove,
            )

          // If we are still running, schedule the next tick
          case did_remove {
            True -> {
              let effects =
                effect.batch([execute_tick(), draw_grid_effect(next_state)])
              #(next_state, effects)
            }
            False -> #(next_state, effect.none())
          }
        }
        False -> {
          #(model, effect.none())
        }
      }
    }

    UserClickedReset -> {
      // 1. Define the reset state
      let reset_model =
        Model(..model, grid: model.initial_grid, count: 0, is_running: False)

      // 2. Return the new state AND the draw effect immediately
      #(reset_model, draw_grid_effect(reset_model))
    }

    UserUpdatedInput(new_text) -> {
      #(Model(..model, input_text: new_text), effect.none())
    }
    UserClickedSubmitData -> {
      let #(h, w, grid) = get_grid(model.input_text)
      let new_model =
        Model(..model, height: h, width: w, grid: grid, initial_grid: grid)
      #(new_model, draw_grid_effect(new_model))
    }
  }
}

fn grid_to_pixel_data(model: Model) -> BitArray {
  // We use a bit_array comprehension or loop to build the bytes
  // Every pixel needs 4 bytes: R, G, B, A
  use acc, y <- list.fold(list.range(0, model.height - 1), <<>>)
  use acc, x <- list.fold(list.range(0, model.width - 1), acc)

  let pixel = case dict.get(model.grid, #(x, y)) {
    Ok("@") -> <<83, 2, 123, 255>>
    _ -> <<222, 157, 255, 255>>
  }

  bit_array.append(acc, pixel)
}

fn make_pixel(x: Int, y: Int) {
  let pixel_size = 8.0
  p.rectangle(pixel_size, pixel_size)
  |> p.fill(p.colour_rgb(150, 150, 150))
  |> p.translate_xy(
    int.to_float(x) *. pixel_size,
    int.to_float(y) *. pixel_size,
  )
}

pub fn render_grid(grid: dict.Dict(#(Int, Int), String)) {
  let grid_to_draw =
    grid
    |> dict.fold([], fn(acc, key, val) {
      case val {
        "@" -> {
          let #(x, y) = key
          let pixel = make_pixel(x, y)
          [pixel, ..acc]
        }
        _ -> acc
      }
    })
  p.combine(grid_to_draw)
}

fn draw_grid_effect(model: Model) -> effect.Effect(Msg) {
  effect.from(fn(_dispatch) {
    // 1. Your existing logic to create the 'Picture'
    let pixels = grid_to_pixel_data(model)

    // 2. Draw it to the canvas with the ID you defined in view
    render_pixels("my-canvas-id", model.width, model.height, pixels)
    Nil
  })
}

// --- 4. VIEW ---
// This turns your state into HTML.
fn view(model: Model) -> Element(Msg) {
  html.div(styles.container_styles(), [
    html.h1([], [
      html.text("Lustre AoC Visualizer"),
    ]),
    html.p([attribute.style("font-size", "x-large")], [
      html.text("Removed rolls: " <> int.to_string(model.count)),
    ]),

    // We can keep the canvas here for your 'paint' logic
    html.canvas([
      attribute.id("my-canvas-id"),
      attribute.width(135),
      attribute.height(135),
      ..styles.canvas_styles()
    ]),
    html.button([event.on_click(UserClickedStart), ..styles.button_styles()], [
      html.text("Start Simulation"),
    ]),
    html.button([event.on_click(UserClickedReset), ..styles.button_styles()], [
      html.text("Reset"),
    ]),
    html.textarea(
      [
        attribute.placeholder("Paste your AoC input here..."),
        attribute.value(model.input_text),
        event.on_input(UserUpdatedInput),
        ..styles.textarea_styles()
      ],
      model.input_text,
    ),
    html.button(
      [event.on_click(UserClickedSubmitData), ..styles.button_styles()],
      [
        html.text("Submit AoC data"),
      ],
    ),
  ])
}

// --- 5. FFI BRIDGE ---
@external(javascript, "./ffi.mjs", "setTimeout")
fn set_timeout(ms: Int, callback: fn() -> Nil) -> Nil

fn execute_tick() -> effect.Effect(Msg) {
  effect.from(fn(dispatch) { set_timeout(100, fn() { dispatch(Tick) }) })
}

@external(javascript, "./ffi.mjs", "render_pixels")
fn render_pixels(id: String, w: Int, h: Int, data: BitArray) -> Nil
