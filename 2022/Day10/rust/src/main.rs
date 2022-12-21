fn main() {
    let content = std::fs::read_to_string("../input.txt").expect("No input...");

    let mut acc: isize = 0;
    let mut x: isize = 1;
    let mut i: usize = 1;
    let mut vec: Vec<char> = Vec::new();

    for line in content.split("\n").filter(|x| !x.is_empty()) {
        let cycles = match line {
            "noop" => 1,
            _ => 2,
        };

        for z in 0..cycles {
            if i == 20 || i == 60 || i == 100 || i == 140 || i == 180 || i == 220 {
                acc += x * (i as isize);
            }

            if (x - (((i as isize) - 1) % 40)).abs() <= 1 {
                vec.push('#');
            } else {
                vec.push(' ');
            }

            if z == 1 {
                x += line[5..].parse::<isize>().expect("Could not parse int...");
            }

            i += 1;
        }
    }

    println!("Solution 1: {}", acc);
    println!("Solution 2:");
    for (i, c) in vec.iter().enumerate() {
        print!("{}{}", c, c);
        if i % 40 == 39 {
            print!("\n");
        }
    }
}
