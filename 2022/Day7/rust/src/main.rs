fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");

    let mut stack: Vec<usize> = Vec::new();
    let mut sizes: Vec<usize> = Vec::new();
    let mut size: usize = 0;
    let mut sum: usize = 0;

    for line in contents
        .split("\n")
        .filter(|x| !x.is_empty() && !(*x == "$ ls") && !x.starts_with("dir"))
        .skip(1)
    {
        if line.starts_with("$") {
            let name = line.split(" ").last().expect("No folder name.");

            if name == ".." {
                if size <= 100000 {
                    sum += size;
                }
                sizes.push(size);
                size += stack.pop().expect("Empty stack...");
                continue;
            }

            stack.push(size);
            size = 0;
        } else {
            let (size_str, _) = line.split_once(" ").expect("Cannot parse file.");
            size += size_str.parse::<usize>().expect("NaN");
        }
    }

    while !stack.is_empty() {
        if size <= 100000 {
            sum += size;
        }
        sizes.push(size);
        size += stack.pop().expect("Empty stack...");
        continue;
    }

    let to_free: usize = 30_000_000 - (70_000_000 - size);
    let delete: &usize = sizes.iter().filter(|&&x| x >= to_free).min().unwrap();

    println!("Solution 1: {}", sum);
    println!("Solution 2: {}", delete);
}
