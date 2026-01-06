import gleam/dict
import gleam/list

pub fn get_el(grid, coord) {
  case dict.get(grid, coord) {
    Ok(s) -> s
    _ -> "."
  }
}

fn get_neighbours(grid, coord) {
  let #(row, col) = coord
  let neighbour_coords = [
    #(row - 1, col - 1),
    #(row - 1, col),
    #(row - 1, col + 1),
    #(row, col - 1),
    #(row, col + 1),
    #(row + 1, col - 1),
    #(row + 1, col),
    #(row + 1, col + 1),
  ]
  list.map(neighbour_coords, fn(coord) { get_el(grid, coord) })
}

fn count_neighbour_rolls(grid, coord) {
  list.fold(get_neighbours(grid, coord), 0, fn(cnt, el) {
    case el == "@" {
      True -> cnt + 1
      False -> cnt
    }
  })
}

pub fn remove_step(
  width: Int,
  height: Int,
  grid: dict.Dict(#(Int, Int), String),
) -> #(Bool, dict.Dict(#(Int, Int), String), Int) {
  list.fold(list.range(0, height - 1), #(False, grid, 0), fn(acc, row) {
    list.fold(list.range(0, width - 1), acc, fn(acc, col) {
      let #(did_remove, grid, count) = acc
      case get_el(grid, #(row, col)) == "@" {
        True -> {
          let neighbour_cnt = count_neighbour_rolls(grid, #(row, col))
          case neighbour_cnt < 4 {
            True -> {
              // Remove this roll
              #(True, dict.delete(grid, #(row, col)), count + 1)
            }
            False -> #(did_remove, grid, count)
          }
        }
        False -> #(did_remove, grid, count)
      }
    })
  })
}
