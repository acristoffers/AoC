#![feature(iter_array_chunks)]

fn encode(line: &str) -> usize {
    line.chars()
        .map(|c| match c {
            'a'..='z' => (c as usize) - ('a' as usize) + 1,
            _ => (c as usize) - ('A' as usize) + 27,
        })
        .fold(0, |encoded, v| encoded | (1 << v))
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");

    let sum1: u32 = contents
        .split("\n")
        .filter(|x| !x.is_empty())
        .map(|line| {
            let (x, y) = line.split_at(line.len() / 2);
            (encode(x) & encode(y)).trailing_zeros()
        })
        .sum();

    let sum2: u32 = contents
        .split("\n")
        .filter(|x| !x.is_empty())
        .array_chunks()
        .map(|[l1, l2, l3]| (encode(l1) & encode(l2) & encode(l3)).trailing_zeros())
        .sum();

    println!("Solution 1: {}", sum1);
    println!("Solution 2: {}", sum2);
}
