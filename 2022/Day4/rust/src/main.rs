use std::str::FromStr;

#[derive(Debug, Clone, Copy)]
struct Range {
    x: usize,
    y: usize,
}

impl Range {
    fn intersects(&self, o: &Range) -> bool {
        self.x <= o.x && self.y >= o.x || self.x <= o.y && self.y >= o.x
    }

    fn contains(&self, o: &Range) -> bool {
        self.x >= o.x && self.y <= o.y
    }
}

impl FromStr for Range {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (l, r) = s.split_once("-").expect("Not a range...");
        Ok(Range {
            x: l.parse().expect("Not a number..."),
            y: r.parse().expect("Not a number..."),
        })
    }
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let ranges: Vec<(Range, Range)> = contents
        .split("\n")
        .filter(|line| !line.is_empty())
        .map(|line| {
            let (sr1, sr2) = line.split_once(",").expect("Weird line...");
            let r1: Range = sr1.parse().expect("Cannot parse...");
            let r2: Range = sr2.parse().expect("Cannot parse...");
            (r1, r2)
        })
        .collect();

    let r1 = ranges
        .iter()
        .filter(|(r1, r2)| r1.contains(&r2) || r2.contains(&r1))
        .count();

    let r2 = ranges.iter().filter(|(r1, r2)| r1.intersects(&r2)).count();

    println!("Solution 1: {}", r1);
    println!("Solution 2: {}", r2);
}
