package year_2026_quest_6

import q "core:container/queue"
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
		{{"./sample_e2026_q06_p1.txt", "./everybody_codes_e2026_q06_p1.txt"}, part_1},
		{{"./sample_e2026_q06_p2.txt", "./everybody_codes_e2026_q06_p2.txt"}, part_2},
		{{"./sample_e2026_q06_p3.txt", "./everybody_codes_e2026_q06_p3.txt"}, part_3},
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

Ingrediant :: distinct int

parse_destroy :: proc(
	ing_to_id: map[string]Ingrediant,
	item_to_ing: map[Ingrediant][dynamic]Ingrediant,
) {
	delete(ing_to_id)
	for k, v in item_to_ing {
		delete(v)
	}
	delete(item_to_ing)
}

parse :: proc(input: string) -> (map[string]Ingrediant, map[Ingrediant][dynamic]Ingrediant, int) {
	content, _ := os.read_entire_file_from_path(input, context.allocator)
	input := string(content)

	id_gen := 0

	ing_to_id := make(map[string]Ingrediant)
	item_to_ing := make(map[Ingrediant][dynamic]Ingrediant)

	// ITEM:INGREDIENT_1,INGREDIENT_2,...
	for line in strings.split_lines_iterator(&input) {
		part, _ := strings.split(line, ":")

		item := part[0]

		id, id_ok := ing_to_id[item]
		if !id_ok {
			id = Ingrediant(id_gen)
			ing_to_id[item] = id
			id_gen += 1
		}
		ing_list := [dynamic]Ingrediant{}
		for ingrediant in strings.split(part[1], ",") {
			ing_id, ok := ing_to_id[ingrediant]
			if !ok {
				ing_id = Ingrediant(id_gen)
				ing_to_id[ingrediant] = ing_id
				id_gen += 1
			}
			append(&ing_list, ing_id)
		}
		item_to_ing[id] = ing_list
	}
	return ing_to_id, item_to_ing, id_gen
}

part_1 :: proc(input: string) {
	ing_to_id, item_to_ing, total_ids := parse(input)
	defer parse_destroy(ing_to_id, item_to_ing)

	used := make([]bool, total_ids)

	task: q.Queue(Ingrediant)
	q.init(&task)
	defer q.destroy(&task)

	null_id, _ := ing_to_id["NULL"]
	q.push_back(&task, null_id)

	for {
		if q.len(task) == 0 {
			break
		}
		id := q.pop_front(&task)
		if used[int(id)] {
			continue
		}

		used[int(id)] = true

		item, exist := item_to_ing[id]
		if exist {
			for i in item {
				if !used[i] {
					q.push_back(&task, i)
				}
			}
		}
	}

	result := -1
	for u in used {
		if u {
			result += 1
		}
	}

	fmt.printfln("[quest 6] [part 1] answer : %d", result)
}

part_2 :: proc(input: string) {
	ing_to_id, item_to_ing, total_ids := parse(input)
	defer parse_destroy(ing_to_id, item_to_ing)

	ing_to_item := make(map[Ingrediant][dynamic]Ingrediant)
	defer {
		for k, v in ing_to_item {
			delete(v)
		}
		delete(ing_to_item)
	}
	for k, v in item_to_ing {
		for item in v {
			ing, exist := ing_to_item[item]
			if !exist {
				ing = [dynamic]Ingrediant{}
			}
			append(&ing, k)
			ing_to_item[item] = ing
		}
	}

	impure := make([]bool, total_ids)

	null_id, _ := ing_to_id["NULL"]


	task: q.Queue(Ingrediant)
	q.init(&task)
	defer q.destroy(&task)

	q.push_back(&task, null_id)

	for {
		if q.len(task) == 0 {
			break
		}

		id := q.pop_front(&task)
		checked := impure[id]

		if checked {
			continue
		}

		impure[id] = true
		items, exist := ing_to_item[id]
		if exist {
			for item in items {
				q.push_back(&task, item)
			}
		}
	}

	result := -1

	for p in impure {
		if p {
			result += 1
		}
	}

	fmt.printfln("[quest 6] [part 2] answer : %d", result)
}


part_3 :: proc(input: string) {
	ing_to_id, item_to_ing, total_ids := parse(input)
	defer parse_destroy(ing_to_id, item_to_ing)

	ing_to_item := make(map[Ingrediant][dynamic]Ingrediant)
	defer {
		for k, v in ing_to_item {
			delete(v)
		}
		delete(ing_to_item)
	}
	for k, v in item_to_ing {
		for item in v {
			ing, exist := ing_to_item[item]
			if !exist {
				ing = [dynamic]Ingrediant{}
			}
			append(&ing, k)
			ing_to_item[item] = ing
		}
	}


	total_impurities := make([]int, total_ids + 1)

	versions := [3]string{"NULLv1", "NULLv2", "NULLv3"}

	for v in 0 ..< 3 {

		impure := make([]bool, total_ids)

		null_id, _ := ing_to_id[versions[v]]


		task: q.Queue(Ingrediant)
		q.init(&task)
		defer q.destroy(&task)

		q.push_back(&task, null_id)

		for {
			if q.len(task) == 0 {
				break
			}

			id := q.pop_front(&task)
			checked := impure[id]

			if checked {
				continue
			}

			impure[id] = true
			items, exist := ing_to_item[id]
			if exist {
				for item in items {
					q.push_back(&task, item)
				}
			}
		}
		for p, i in impure {
			if p {
				total_impurities[i] += 1
			}
		}
	}

	result := 0

	versions_id := [3]Ingrediant{}
	for v, i in versions {
		id, _ := ing_to_id[v]
		versions_id[i] = id
	}
	for p in total_impurities {
		if p > 1 {
			is_version_id := false
			for v in versions_id {
				is_version_id = is_version_id || p == int(v)
			}
			if !is_version_id {
				result += 1
			}
		}
	}

	fmt.printfln("[quest 6] [part 3] answer : %d", result)
}
