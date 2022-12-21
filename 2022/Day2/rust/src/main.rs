use anyhow::anyhow;
use std::str::FromStr;

#[derive(Debug, Copy, Clone)]
enum Play {
    Rock = 0,
    Paper = 1,
    Scisor = 2,
}
use Play::*;

impl Play {
    fn points(self: &Play, other: &Play) -> usize {
        let hand: usize = match self {
            Play::Rock => 1,
            Play::Paper => 2,
            Play::Scisor => 3,
        };

        let outcome: usize = match (self, other) {
            (Rock, Scisor) => 6,
            (Paper, Rock) => 6,
            (Scisor, Paper) => 6,
            (Rock, Rock) => 3,
            (Paper, Paper) => 3,
            (Scisor, Scisor) => 3,
            _ => 0,
        };

        return hand + outcome;
    }
}

impl FromStr for Play {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "A" => Ok(Rock),
            "B" => Ok(Paper),
            "C" => Ok(Scisor),
            "X" => Ok(Rock),
            "Y" => Ok(Paper),
            "Z" => Ok(Scisor),
            _ => Err(anyhow!("Wrong hand")),
        }
    }
}

#[derive(Debug, Clone, Copy)]
enum Outcome {
    Lose = 0,
    Draw = 1,
    Win = 2,
}
use Outcome::*;

impl Outcome {
    fn points(self: &Outcome, other: &Play) -> usize {
        let victory = (*self as isize) * 3;

        let hand: isize = match self {
            Lose => (*other as isize) - 1,
            Draw => *other as isize,
            Win => (*other as isize) + 1,
        };

        (victory + hand.rem_euclid(3) + 1)
            .try_into()
            .expect("Not big enough :O")
    }
}

impl FromStr for Outcome {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "X" => Ok(Lose),
            "Y" => Ok(Draw),
            "Z" => Ok(Win),
            _ => Err(anyhow!("Wrong hand")),
        }
    }
}

#[derive(Debug)]
struct Hand {
    x: Play,
    y: Play,
    z: Outcome,
}

impl FromStr for Hand {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let splited: Vec<&str> = s.split(" ").collect();
        Ok(Hand {
            x: (*splited.first().unwrap()).parse()?,
            y: (*splited.last().unwrap()).parse()?,
            z: (*splited.last().unwrap()).parse()?,
        })
    }
}

fn main() -> Result<(), anyhow::Error> {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let hands: Vec<Hand> = contents
        .split("\n")
        .filter_map(|line| line.parse::<Hand>().ok())
        .collect();

    let r1: usize = hands.iter().map(|hand| hand.y.points(&hand.x)).sum();
    let r2: usize = hands.iter().map(|hand| hand.z.points(&hand.x)).sum();

    println!("Solution 1: {}", r1);
    println!("Solution 2: {}", r2);
    Ok(())
}
