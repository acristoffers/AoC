use std::collections::HashMap;

#[derive(Debug)]
struct Cave {
    rocks: HashMap<[usize; 2], ()>,
    sand: HashMap<[usize; 2], ()>,
    min_x: usize,
    max_x: usize,
    min_y: usize,
    max_y: usize,
}

impl Cave {
    fn parse_rocks(&mut self, chain: &str) {
        let mut lp: [usize; 2] = [0, 0];
        for point in chain.split("->").map(|s| s.trim()) {
            let (x, y) = point.split_once(',').expect("Not a point?");
            let p: [usize; 2] = [x.parse().unwrap(), y.parse().unwrap()];

            if lp != [0, 0] {
                if p[0] != lp[0] {
                    let j = p[0].min(lp[0]);
                    let k = p[0].max(lp[0]);
                    for i in j..=k {
                        self.rocks.insert([i, p[1]], ());
                    }
                } else if p[1] != lp[1] {
                    let j = p[1].min(lp[1]);
                    let k = p[1].max(lp[1]);
                    for i in j..=k {
                        self.rocks.insert([p[0], i], ());
                    }
                }
            }

            lp = p
        }
    }

    fn fall(&mut self, floor: bool) -> bool {
        let mut p = [500, 0];

        'outer: loop {
            if !floor && p[1] > self.max_y + 2 {
                return false;
            }

            if floor && p[1] == self.max_y + 1 {
                self.sand.insert(p, ());
                return true;
            }

            for c in [[p[0], p[1] + 1], [p[0] - 1, p[1] + 1], [p[0] + 1, p[1] + 1]] {
                if !self.rocks.contains_key(&c) && !self.sand.contains_key(&c) {
                    p = c;
                    continue 'outer;
                }
            }

            if p == [500, 0] {
                return false;
            }

            self.sand.insert(p, ());
            return true;
        }
    }

    // fn print(&self, floor: bool) {
    //     let max_y = if floor { self.max_y + 2 } else { self.max_y };
    //     for y in self.min_y..=max_y {
    //         for x in self.min_x..=self.max_x {
    //             let mut c = '.';
    //             if self.rocks.contains_key(&[x, y]) {
    //                 c = '#';
    //             } else if self.sand.contains_key(&[x, y]) {
    //                 c = 'O';
    //             } else if [x, y] == [500, 0] {
    //                 c = '+';
    //             } else if y == max_y && floor {
    //                 c = '#';
    //             }
    //             print!("{c}");
    //         }
    //         println!();
    //     }
    // }
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let mut cave = Cave {
        rocks: HashMap::with_capacity(5000),
        sand: HashMap::with_capacity(50000),
        min_x: 10000000,
        max_x: 0,
        min_y: 10000000,
        max_y: 0,
    };

    for chain in contents.split('\n').filter(|s| !s.is_empty()) {
        cave.parse_rocks(chain);
    }

    cave.min_x = cave.rocks.keys().min_by(|[x, _], [z, _]| x.cmp(z)).unwrap()[0];
    cave.max_x = cave.rocks.keys().max_by(|[x, _], [z, _]| x.cmp(z)).unwrap()[0];
    cave.min_y = cave.rocks.keys().min_by(|[_, y], [_, z]| y.cmp(z)).unwrap()[1];
    cave.max_y = cave.rocks.keys().max_by(|[_, y], [_, z]| y.cmp(z)).unwrap()[1];

    while cave.fall(false) {}
    // cave.print(false);
    println!("Solution 1: {}", cave.sand.len());

    while cave.fall(true) {}
    cave.min_x = cave.sand.keys().min_by(|[x, _], [z, _]| x.cmp(z)).unwrap()[0];
    cave.max_x = cave.sand.keys().max_by(|[x, _], [z, _]| x.cmp(z)).unwrap()[0];
    // cave.print(true);
    println!("Solution 2: {}", cave.sand.len() + 1);
}
