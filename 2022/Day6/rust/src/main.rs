fn search_in_window(contents: &String, n: usize) -> usize {
    for j in 0..contents.len() {
        let mut window: Vec<char> = contents.chars().skip(j).take(n).collect();
        window.sort();
        window.dedup();
        if window.len() == n {
            return j + n;
        }
    }

    return 0;
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("Input not found");

    let r1 = search_in_window(&contents, 4);
    let r2 = search_in_window(&contents, 14);

    println!("Solution 1: {}", r1);
    println!("Solution 2: {}", r2);
}
