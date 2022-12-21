fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let mut chunks: Vec<usize> = contents
        .split("\n\n")
        .map(|block| {
            block
                .split("\n")
                .filter_map(|num_str| num_str.parse::<usize>().ok())
                .sum::<usize>()
        })
        .collect();

    chunks.sort_unstable();
    chunks.reverse();

    println!("Solution 1: {:?}", chunks.first().unwrap());
    println!("Solution 2: {:?}", chunks.iter().take(3).sum::<usize>());
}
