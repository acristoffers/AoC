#![feature(iter_array_chunks)]

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No file...");
    let (head, commands) = contents.split_once("\n\n").expect("Oh oh");

    let mut stacks: Vec<Vec<char>> = vec![Vec::new(); 9];
    for line in head.split("\n") {
        if line.chars().nth(1) == Some('1') {
            continue;
        }

        for (i, [_, c, _, _]) in line.chars().array_chunks().enumerate() {
            if c == ' ' {
                continue;
            }

            stacks[i].push(c);
        }
    }

    for s in &mut stacks {
        s.reverse();
    }

    let mut stacks9001 = stacks.clone();

    for line in commands.split("\n") {
        if line.is_empty() {
            continue;
        }

        let line: Vec<usize> = line
            .split(" ")
            .filter_map(|x| x.parse::<usize>().ok())
            .collect();

        let n = line[0];
        let from = line[1] - 1;
        let to = line[2] - 1;

        for _ in 0..n {
            let v = stacks[from].pop().expect("Empty stack?");
            stacks[to].push(v);
        }

        let i = stacks9001[from].len() - n;
        let mut v9001: Vec<char> = stacks9001[from].drain(i..).collect();
        stacks9001[to].append(&mut v9001);
    }

    let r1: String = stacks.iter().filter_map(|x| x.last()).collect();
    let r2: String = stacks9001.iter().filter_map(|x| x.last()).collect();

    println!("Solution 1: {}", r1);
    println!("Solution 2: {}", r2);
}
