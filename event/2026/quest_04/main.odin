package year_2026_quest_4

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
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
		{{"./sample_e2026_q04_p1.txt", "./everybody_codes_e2026_q04_p1.txt"}, part_1},
		{{"./sample_e2026_q04_p2.txt", "./everybody_codes_e2026_q04_p2.txt"}, part_2},
		{
			{
				"./sample_e2026_q04_p3.txt",
				"./sample_e2026_q04_p3_2.txt",
				"./sample_e2026_q04_p3_3.txt",
				"./everybody_codes_e2026_q04_p3.txt",
			},
			part_3,
		},
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


Participation :: struct {
	id:    int,
	quest: int,
	part:  int,
	t:     int,
}

parse :: proc(file: string) -> [dynamic]Participation {
	data, _ := os.read_entire_file_from_path(file, context.allocator)
	input := string(data)
	quest := [dynamic]Participation{}

	for line in strings.split_lines_iterator(&input) {
		part := strings.split(line, " ", context.temp_allocator)
		participation := Participation{}

		token := strings.split(part[0], "=", context.temp_allocator)
		participation.id, _ = strconv.parse_int(token[1], 10)

		token = strings.split(part[1], "=", context.temp_allocator)
		participation.quest, _ = strconv.parse_int(token[1], 10)

		token = strings.split(part[2], "=", context.temp_allocator)
		participation.part, _ = strconv.parse_int(token[1], 10)

		token = strings.split(part[3], "=", context.temp_allocator)
		participation.t, _ = strconv.parse_int(token[1], 10)
		append(&quest, participation)
	}

	return quest
}

part_1 :: proc(file: string) {
	participations := parse(file)
	defer delete(participations)

	times := [dynamic]int{}
	defer delete(times)

	for i in 1 ..< (len(participations) + 1) {
		t := 0
		for p in participations {
			if int(p.id) == i {
				t += int(p.t)
			}
		}
		if t > 0 {
			append(&times, t)
		}
	}
	slice.sort(times[:])
	result := 0
	for t, i in times {
		result += (i + 1) * t
	}
	fmt.printfln("result : %d", result)
}

part_2 :: proc(file: string) {
	participations := parse(file)
	defer delete(participations)

	Info :: struct {
		parts: int,
		t:     int,
	}

	id_to_info := map[int]Info{}
	defer delete(id_to_info)

	for p in participations {
		info, ok := id_to_info[p.id]
		if !ok {
			info = {}
		}
		info.parts += 1
		info.t += p.t
		id_to_info[p.id] = info
	}
	infos := make([]Info, len(id_to_info))
	defer delete(infos)
	i := 0
	for k, v in id_to_info {
		infos[i] = v
		i += 1
	}
	slice.sort_by_cmp(infos, proc(a, b: Info) -> slice.Ordering {
		if a.parts > b.parts {
			return .Less
		} else if a.parts < b.parts {
			return .Greater
		}
		return .Less if a.t <= b.t else .Greater
	})
	result := 0
	for i, idx in infos {
		result += (idx + 1) * i.t
	}
	fmt.printfln("result : %d", result)
}

part_3 :: proc(file: string) {
	participations := parse(file)
	defer delete(participations)


	id_to_point := map[int]int{}
	defer delete(id_to_point)

	quest_count := 0
	for p in participations {
		quest_count = max(quest_count, p.quest)
	}


	points := [3]int{50, 100, 150}

	for q in 1 ..< quest_count + 1 {
		id_to_time := map[int]int{}
		defer delete(id_to_time)
		for part in 1 ..< 4 {
			Info :: struct {
				id: int,
				t:  int,
			}
			infos := [dynamic]Info{}
			for p in participations {
				if p.quest != q || p.part != part {
					continue
				}
				t, ok := id_to_time[p.id]
				if !ok {
					t = 0
				}
				t += p.t
				id_to_time[p.id] = t
				append(&infos, {p.id, t})
			}
			slice.sort_by_cmp(infos[:], proc(a, b: Info) -> slice.Ordering {
				return .Less if a.t < b.t else .Greater
			})

			current_point := points[part - 1]
			to_reduce := 1
			for info, i in infos {
				if i > 0 {
					if infos[i - 1].t == infos[i].t {
						to_reduce += 1
					} else {
						current_point -= to_reduce
						current_point = max(current_point, 0)
						to_reduce = 1
					}
				}
				point, ok := id_to_point[info.id]
				if !ok {
					point = 0
				}
				point += current_point
				id_to_point[info.id] = point
			}
		}
	}

	arr := [dynamic]int{}
	defer delete(arr)

	for k, v in id_to_point {
		append(&arr, v)
	}
	slice.sort(arr[:])
	slice.reverse(arr[:])

	result := 0
	current_rank := 1
	increase_by := 0
	for info, i in arr {
		if i > 0 && arr[i] == arr[i - 1] {
			increase_by += 1
		} else {
			current_rank += increase_by
			increase_by = 1
		}
		result += current_rank * info
	}
	fmt.printfln("result : %d", result)
}
