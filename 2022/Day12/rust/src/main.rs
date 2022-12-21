use std::collections::HashMap;
use std::collections::HashSet;

fn a_star(start: [usize; 2], target: [usize; 2], map: &Vec<Vec<char>>) -> usize {
    let mut closed = HashSet::<[usize; 2]>::new();
    let mut open = HashSet::<[usize; 2]>::new();
    let mut current = start;
    let mut scores: HashMap<[usize; 2], [usize; 5]> = HashMap::new();

    open.insert(start);
    scores.insert(start, [0, 0, 0, start[0], start[1]]);

    while current != target {
        current = open
            .iter()
            .min_by(|&a, &b| scores[a][2].cmp(&scores[b][2]))
            .expect("Empty open stack.")
            .to_owned();
        open.remove(&current);
        closed.insert(current);

        for i in -1..=1isize {
            for j in -1..=1isize {
                if i.abs() == j.abs() {
                    continue;
                }

                let nx: usize = match current[0].checked_add_signed(i) {
                    Some(x) => x,
                    None => continue,
                };

                let ny: usize = match current[1].checked_add_signed(j) {
                    Some(x) => x,
                    None => continue,
                };

                if nx < map.len() && ny < map[0].len() {
                    let neighbour = [nx, ny];
                    let c_score = scores.get(&current).unwrap_or(&[0, 0, 0, 0, 0]);
                    let n_score = scores.get(&neighbour).unwrap_or(&[0, 0, 0, 0, 0]);
                    let n_height = map[nx][ny];
                    let c_height = map[current[0]][current[1]];

                    if n_height as u32 <= c_height as u32 + 1 {
                        if closed.contains(&neighbour) {
                            continue;
                        }

                        let is_neighbour_in_open = open.contains(&neighbour);

                        if !(!is_neighbour_in_open || c_score[0] + 1 < n_score[0]) {
                            continue;
                        }

                        let a = (nx as isize - target[0] as isize).unsigned_abs();
                        let b = (ny as isize - target[1] as isize).unsigned_abs();
                        let new_score = [
                            c_score[0] + 1,
                            a + b,
                            c_score[0] + 1 + a + b,
                            current[0],
                            current[1],
                        ];

                        scores.insert(neighbour, new_score);

                        if !is_neighbour_in_open {
                            open.insert(neighbour);
                        }
                    }
                }
            }
        }
    }

    let mut count = 0;
    let mut cur_score = scores[&current];
    while current != start {
        current = cur_score[3..].try_into().expect("Impossibru!");
        cur_score = scores[&current];
        count += 1;
    }

    return count;
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let mut map: Vec<Vec<char>> = contents
        .split("\n")
        .filter(|x| !x.is_empty())
        .map(|x| x.chars().collect::<Vec<char>>())
        .collect();

    let start = if let Some(len) = contents.find("S") {
        [len / (map[0].len() + 1), len % (map[0].len() + 1)]
    } else {
        panic!("No start");
    };

    let end = if let Some(len) = contents.find("E") {
        [len / (map[0].len() + 1), len % (map[0].len() + 1)]
    } else {
        panic!("No end");
    };

    map[start[0]][start[1]] = 'a';
    map[end[0]][end[1]] = 'z';

    let count = a_star(start, end, &map);
    println!("Solution 1: {}", count);

    let mut min: usize = 100000;
    for i in 0..map.len() {
        min = a_star([i, 0], end, &map).min(min);
    }
    println!("Solution 2: {}", min);
}
