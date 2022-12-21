use std::collections::HashMap;
use std::hash::Hash;
use std::str::FromStr;

#[derive(Copy, Clone, Debug)]
struct Point {
    x: isize,
    y: isize,
}

impl Eq for Point {
    fn assert_receiver_is_total_eq(&self) {}
}

impl PartialEq for Point {
    fn eq(&self, other: &Self) -> bool {
        self.x == other.x && self.y == other.y
    }
}

impl Hash for Point {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.x.hash(state);
        self.y.hash(state);
    }
}

impl Point {
    fn move_head(self: &mut Point, direction: Direction) {
        match direction {
            Direction::Right => {
                self.x = self.x + 1;
                self.y = self.y;
            }
            Direction::Left => {
                self.x = self.x - 1;
                self.y = self.y;
            }
            Direction::Up => {
                self.y = self.y + 1;
                self.x = self.x;
            }
            Direction::Down => {
                self.y = self.y - 1;
                self.x = self.x;
            }
        }
    }

    fn move_tail(self: &mut Point, head: &Point) {
        let dx = head.x - self.x;
        let dy = head.y - self.y;
        if dx * dx + dy * dy > 2 {
            self.x = self.x + dx.signum();
            self.y = self.y + dy.signum();
        }
    }
}

#[derive(Copy, Clone, Debug)]
enum Direction {
    Right,
    Left,
    Up,
    Down,
}

impl FromStr for Direction {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "R" => Ok(Direction::Right),
            "L" => Ok(Direction::Left),
            "U" => Ok(Direction::Up),
            "D" => Ok(Direction::Down),
            _ => unreachable!(),
        }
    }
}

#[derive(Copy, Clone, Debug)]
struct Command {
    direction: Direction,
    steps: usize,
}

impl FromStr for Command {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (d, n) = s.split_once(" ").expect("Cannot parse input.");
        let command = Command {
            direction: d.parse()?,
            steps: n.parse()?,
        };
        Ok(command)
    }
}

fn simulate(commands: &Vec<Command>, size: usize) -> usize {
    let mut snake: Vec<Point> = Vec::new();
    for _ in 0..size {
        snake.push(Point { x: 0, y: 0 });
    }

    let mut tail: HashMap<Point, ()> = HashMap::new();

    for command in commands {
        for _ in 0..command.steps {
            snake[0].move_head(command.direction);
            for i in 1..snake.len() {
                let head = snake[i - 1];
                snake[i].move_tail(&head);
            }
            tail.insert(snake[snake.len() - 1], ());
        }
    }

    return tail.len();
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let commands: Vec<Command> = contents
        .split("\n")
        .filter(|x| !x.is_empty())
        .filter_map(|x| x.parse().ok())
        .collect();

    let r1 = simulate(&commands, 2);
    let r2 = simulate(&commands, 10);

    println!("Solution 1: {}", r1);
    println!("Solution 2: {}", r2);
}
