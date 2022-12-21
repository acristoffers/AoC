fn is_visible(map: &Vec<Vec<char>>, i: usize, j: usize) -> bool {
    if i == 0 || j == 0 || i >= map.len() - 1 || j >= map[0].len() - 1 {
        return true;
    }
    let mut blocks = false;
    for k in 0..i {
        blocks |= map[k][j] >= map[i][j];
    }
    if !blocks {
        return true;
    }
    blocks = false;
    for k in i + 1..map.len() {
        blocks |= map[k][j] >= map[i][j];
    }
    if !blocks {
        return true;
    }
    blocks = false;
    for k in 0..j {
        blocks |= map[i][k] >= map[i][j];
    }
    if !blocks {
        return true;
    }
    blocks = false;
    for k in j + 1..map[0].len() {
        blocks |= map[i][k] >= map[i][j];
    }
    return !blocks;
}

fn scenic_score(map: &Vec<Vec<char>>, i: usize, j: usize) -> usize {
    let mut score = 1;
    let mut s = 0;
    for k in (0..i).rev() {
        s += 1;
        if map[k][j] >= map[i][j] {
            break;
        }
    }
    score *= s;
    s = 0;
    for k in i + 1..map.len() {
        s += 1;
        if map[k][j] >= map[i][j] {
            break;
        }
    }
    score *= s;
    s = 0;
    for k in (0..j).rev() {
        s += 1;
        if map[i][k] >= map[i][j] {
            break;
        }
    }
    score *= s;
    s = 0;
    for k in j + 1..map[0].len() {
        s += 1;
        if map[i][k] >= map[i][j] {
            break;
        }
    }
    return score * s;
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let map: Vec<Vec<char>> = contents
        .split("\n")
        .filter(|x| !x.is_empty())
        .map(|s| s.chars().collect())
        .collect();

    let mut count = 0;
    let mut score: usize = 0;
    for i in 0..map.len() {
        for j in 0..map[0].len() {
            score = score.max(scenic_score(&map, i, j));
            if is_visible(&map, i, j) {
                count += 1;
            }
        }
    }

    println!("Solution 1: {}", count);
    println!("Solution 2: {}", score);
}
