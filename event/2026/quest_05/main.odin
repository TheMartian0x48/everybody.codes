package year_2026_quest_5

import "core:container/queue"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {

	abs_path := proc(f: string) -> string {
		location := #location()
		folder, _ := strings.substring(
			location.file_path,
			0,
			strings.last_index_any(location.file_path, "/"),
		)

		return strings.join([]string{folder, f}, "/")
	}

	Task :: struct {
		files: []string,
		fn:    proc(_: string),
	}

	quest := []Task {
		{{"./sample_e2026_q05_p1.txt", "./everybody_codes_e2026_q05_p1.txt"}, part_1},
		{{"./sample_e2026_q05_p2.txt", "./everybody_codes_e2026_q05_p2.txt"}, part_2},
		{{"./sample_e2026_q05_p3.txt", "./everybody_codes_e2026_q05_p3.txt"}, part_3},
	}

	for q in quest {
		for f in q.files {
			fmt.println("\n<===============================================>")
			fmt.printfln("\n[%s]\n", f)
			file := abs_path(f)
			defer delete(file)
			q.fn(file)
		}
	}

}


Coordinate :: struct {
	row, col: int,
}

create_grid :: proc(input: string) -> [dynamic][dynamic]u8 {
	content, _ := os.read_entire_file_from_path(input, context.allocator)
	input := string(content)
	grid := [dynamic][dynamic]u8{}
	for line in strings.split_lines_iterator(&input) {
		grid_row := [dynamic]u8{}
		for c in transmute([]u8)line {
			append(&grid_row, c)
		}
		append(&grid, grid_row)
	}
	return grid
}

part_1 :: proc(input: string) {
	grid := create_grid(input)

	row_count := len(grid)
	col_count := len(grid[0])

	queued := [dynamic][dynamic]bool{}
	for r in 0 ..< row_count {
		row := [dynamic]bool{}
		for c in 0 ..< col_count {
			append(&row, false)
		}
		append(&queued, row)
	}

	task: queue.Queue(Coordinate)
	queue.init(&task)
	defer queue.destroy(&task)


	dir_c := [8]int{-1, 0, 1, 0, -1, -1, 1, 1}
	dir_r := [8]int{0, -1, 0, 1, -1, 1, -1, 1}

	queue.push_back(&task, {row_count / 2, col_count / 2})
	grid[row_count / 2][col_count / 2] = '#'


	for {
		if queue.len(task) == 0 {
			break
		}

		t := queue.pop_front(&task)
		r, c := t.row, t.col
		queued[r][c] = false
		qualifier_count := 0
		for i in 0 ..< 8 {
			rr := r + dir_r[i]
			cc := c + dir_c[i]
			if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
				continue
			}
			if grid[rr][cc] == '#' || grid[rr][cc] == '1' {
				qualifier_count += 1
			}
		}
		if qualifier_count >= 5 || (r == (row_count / 2) && c == (col_count / 2)) {
			grid[r][c] = '#'
			for i in 0 ..< 8 {
				rr := r + dir_r[i]
				cc := c + dir_c[i]
				if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
					continue
				}
				if grid[rr][cc] != '#' && queued[rr][cc] == false {
					queued[rr][cc] = true
					queue.push_back(&task, {rr, cc})
				}
			}
		}
	}


	result := 0
	for r in 0 ..< row_count {
		for c in 0 ..< col_count {
			result += 1 if grid[r][c] == '#' else 0
		}
	}

	fmt.printfln("Result : %d", result)
}

part_2 :: proc(input: string) {
	grid := create_grid(input)

	row_count := len(grid)
	col_count := len(grid[0])

	queued := [dynamic][dynamic]bool{}
	for r in 0 ..< row_count {
		row := [dynamic]bool{}
		for c in 0 ..< col_count {
			append(&row, false)
		}
		append(&queued, row)
	}

	task: queue.Queue(Coordinate)
	queue.init(&task)
	defer queue.destroy(&task)


	dir_c := [8]int{-1, 0, 1, 0, -1, -1, 1, 1}
	dir_r := [8]int{0, -1, 0, 1, -1, 1, -1, 1}

	queue.push_back(&task, {row_count / 2, col_count / 2})
	grid[row_count / 2][col_count / 2] = '#'


	for {
		if queue.len(task) == 0 {
			break
		}

		t := queue.pop_front(&task)
		r, c := t.row, t.col
		queued[r][c] = false
		qualifier_count := 0
		for i in 0 ..< 8 {
			rr := r + dir_r[i]
			cc := c + dir_c[i]
			if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
				continue
			}
			if grid[rr][cc] == '#' || grid[rr][cc] == '1' {
				qualifier_count += 1
			}
		}
		if qualifier_count >= 5 || (r == (row_count / 2) && c == (col_count / 2)) {
			grid[r][c] = '#'
			for i in 0 ..< 8 {
				rr := r + dir_r[i]
				cc := c + dir_c[i]
				if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
					continue
				}
				if grid[rr][cc] != '#' && queued[rr][cc] == false {
					queued[rr][cc] = true
					queue.push_back(&task, {rr, cc})
				}
			}
		}
	}

	for r in 0 ..< row_count {
		for c in 0 ..< col_count {
			grid[r][c] = '#' if grid[r][c] == '#' else '.'
		}
	}

	for r in 0 ..< row_count {
		for c in 0 ..< col_count {
			if grid[r][c] == '#' {
				for i in 0 ..< 8 {
					rr := r + dir_r[i]
					cc := c + dir_c[i]
					if rr < 0 ||
					   cc < 0 ||
					   rr >= row_count ||
					   cc >= col_count ||
					   grid[rr][cc] == '.' {
						queued[r][r] = true
						queue.push_back(&task, {r, c})
						grid[r][c] = '='
						break
					}
				}
			}
		}
	}

	for {
		if queue.len(task) == 0 {
			break
		}

		t := queue.pop_front(&task)
		r, c := t.row, t.col
		queued[r][c] = false

		if grid[r][c] == '=' {
			for i in 0 ..< 8 {
				rr := r + dir_r[i]
				cc := c + dir_c[i]
				if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
					continue
				}
				if grid[rr][cc] == '#' {
					if queued[rr][cc] == false {
						queued[rr][cc] = true
						queue.push_back(&task, {rr, cc})
					}
				}
			}
		} else {
			qualifier_count := 0
			for i in 0 ..< 8 {
				rr := r + dir_r[i]
				cc := c + dir_c[i]
				if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
					continue
				}
				if grid[rr][cc] == '=' {
					qualifier_count += 1
				}
			}
			if qualifier_count >= 5 {
				grid[r][c] = '='
				for i in 0 ..< 8 {
					rr := r + dir_r[i]
					cc := c + dir_c[i]
					if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
						continue
					}
					if grid[rr][cc] == '#' && queued[rr][cc] == false {
						queued[rr][cc] = true
						queue.push_back(&task, {rr, cc})
					}
				}
			}
		}
	}

	result := 0
	for r in 0 ..< row_count {
		for c in 0 ..< col_count {
			result += 1 if grid[r][c] == '=' else 0
		}
	}

	fmt.printfln("Result : %d", result)
}

part_3 :: proc(input: string) {
	grid := create_grid(input)

	row_count := len(grid)
	col_count := len(grid[0])

	queued := [dynamic][dynamic]bool{}
	for r in 0 ..< row_count {
		row := [dynamic]bool{}
		for c in 0 ..< col_count {
			append(&row, false)
		}
		append(&queued, row)
	}

	task: queue.Queue(Coordinate)
	queue.init(&task)
	defer queue.destroy(&task)


	dir_c := [8]int{-1, 0, 1, 0, -1, -1, 1, 1}
	dir_r := [8]int{0, -1, 0, 1, -1, 1, -1, 1}

	queue.push_back(&task, {row_count / 2, col_count / 2})
	grid[row_count / 2][col_count / 2] = '#'


	for {
		if queue.len(task) == 0 {
			break
		}

		t := queue.pop_front(&task)
		r, c := t.row, t.col
		queued[r][c] = false
		qualifier_count := 0
		for i in 0 ..< 8 {
			rr := r + dir_r[i]
			cc := c + dir_c[i]
			if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
				continue
			}
			if grid[rr][cc] == '#' || grid[rr][cc] == '1' {
				qualifier_count += 1
			}
		}
		if qualifier_count >= 5 || (r == (row_count / 2) && c == (col_count / 2)) {
			grid[r][c] = '#'
			for i in 0 ..< 8 {
				rr := r + dir_r[i]
				cc := c + dir_c[i]
				if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
					continue
				}
				if grid[rr][cc] != '#' && queued[rr][cc] == false {
					queued[rr][cc] = true
					queue.push_back(&task, {rr, cc})
				}
			}
		}
	}

	for r in 0 ..< row_count {
		for c in 0 ..< col_count {
			grid[r][c] = '#' if grid[r][c] == '#' else '.'
		}
	}

	for r in 0 ..< row_count {
		for c in 0 ..< col_count {
			if grid[r][c] == '#' {
				for i in 0 ..< 8 {
					rr := r + dir_r[i]
					cc := c + dir_c[i]
					if rr < 0 ||
					   cc < 0 ||
					   rr >= row_count ||
					   cc >= col_count ||
					   grid[rr][cc] == '.' {
						queued[r][r] = true
						queue.push_back(&task, {r, c})
						grid[r][c] = '='
						break
					}
				}
			}
		}
	}


	for {
		if queue.len(task) == 0 {
			break
		}

		t := queue.pop_front(&task)
		r, c := t.row, t.col
		queued[r][c] = false


		if grid[r][c] == '=' {
			for i in 0 ..< 8 {
				rr := r + dir_r[i]
				cc := c + dir_c[i]
				if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
					continue
				}
				if grid[rr][cc] == '#' {
					if queued[rr][cc] == false {
						queued[rr][cc] = true
						queue.push_back(&task, {rr, cc})
					}
				}
			}
		} else {
			qualifier_count := 0
			for i in 0 ..< 8 {
				rr := r + dir_r[i]
				cc := c + dir_c[i]
				if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
					continue
				}
				if grid[rr][cc] == '=' {
					qualifier_count += 1
				}
			}
			if qualifier_count >= 5 {
				grid[r][c] = '='
				for i in 0 ..< 8 {
					rr := r + dir_r[i]
					cc := c + dir_c[i]
					if rr < 0 || cc < 0 || rr >= row_count || cc >= col_count {
						continue
					}
					if grid[rr][cc] == '#' && queued[rr][cc] == false {
						queued[rr][cc] = true
						queue.push_back(&task, {rr, cc})
					}
				}
			}
		}
	}

	dir_r5 := [dynamic]int{}
	dir_c5 := [dynamic]int{}

	for r in -2 ..< 3 {
		for c in -2 ..< 3 {
			if (abs(r) == 2 && abs(c) == 2) || (r == 0 && c == 0) {
				continue
			}
			append(&dir_r5, r)
			append(&dir_c5, c)
		}
	}

	for r in 0 ..< row_count {
		for c in 0 ..< col_count {
			if grid[r][c] == '#' {
				queued[r][c] = true
				queue.push_back(&task, {r, c})
			}
		}
	}

	for {
		if queue.len(task) == 0 {
			break
		}

		t := queue.pop_front(&task)
		r, c := t.row, t.col

		queued[r][c] = false

		qualify := true
		for i in 0 ..< len(dir_r5) {
			rr := dir_r5[i] + r
			cc := dir_c5[i] + c
			if rr < 0 ||
			   cc < 0 ||
			   rr >= row_count ||
			   cc >= col_count ||
			   !(grid[rr][cc] == '#' || grid[rr][cc] == '@') {
				qualify = false
				break
			}
		}
		if qualify {
			grid[r][c] = '@'
			for i in 0 ..< len(dir_r) {
				rr := dir_r[i] + r
				cc := dir_c[i] + c
				if rr < 0 ||
				   cc < 0 ||
				   rr >= row_count ||
				   cc >= col_count ||
				   grid[rr][cc] != '#' ||
				   queued[rr][cc] == true {
					continue
				}
				queued[rr][cc] = true
				queue.push_back(&task, {rr, cc})
			}
		}
	}

	for step in 0 ..< 2 {
		for r in 0 ..< row_count {
			for c in 0 ..< col_count {
				if grid[r][c] != '#' {
					continue
				}
				has_sand := false
				trees := 0
				for i in 0 ..< len(dir_r) {
					rr := dir_r[i] + r
					cc := dir_c[i] + c
					has_sand = has_sand || grid[rr][cc] == '='
					trees += 1 if grid[rr][cc] == '@' else 0
				}
				if !has_sand && trees >= 4 {
					grid[r][c] = 'T'
				}
			}
		}
		for r in 0 ..< row_count {
			for c in 0 ..< col_count {
				grid[r][c] = '@' if grid[r][c] == 'T' else grid[r][c]
			}
		}
	}


	result := 0
	for r in 0 ..< row_count {
		for c in 0 ..< col_count {
			result += 1 if grid[r][c] == '@' else 0
		}
	}

	fmt.printfln("Result : %d", result)
}
