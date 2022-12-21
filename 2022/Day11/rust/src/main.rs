use anyhow::anyhow;
use std::str::FromStr;

#[derive(Clone, Copy, Debug)]
enum Operator {
    Add,
    Mul,
}

#[derive(Clone, Copy, Debug)]
struct Operation {
    operator: Operator,
    lhs: Option<usize>,
    rhs: Option<usize>,
}

impl Operation {
    fn calculate(self: &Self, x: usize) -> usize {
        let lhs = self.lhs.unwrap_or(x);
        let rhs = self.rhs.unwrap_or(x);
        match self.operator {
            Operator::Add => lhs + rhs,
            Operator::Mul => lhs * rhs,
        }
    }
}

impl FromStr for Operation {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (_, line) = s.split_once("=").expect("Cannot parse operation.");
        let tokens: Vec<&str> = line.trim().split(" ").collect();
        let operator = Operation {
            lhs: tokens[0].parse().ok(),
            operator: if tokens[1] == "+" {
                Operator::Add
            } else {
                Operator::Mul
            },
            rhs: tokens[2].parse().ok(),
        };
        Ok(operator)
    }
}

#[derive(Clone, Debug)]
struct Monkey {
    items: Vec<usize>,
    operation: Operation,
    test: usize,
    when_true: usize,
    when_false: usize,
    business: usize,
}

impl FromStr for Monkey {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let lines: Vec<&str> = s.split("\n").skip(1).collect();
        let monkey = Monkey {
            items: lines[0]
                .split(":")
                .last()
                .ok_or(anyhow!("No last element when parsing items in monkey."))?
                .split(", ")
                .map(|x| x.trim())
                .filter_map(|x| x.parse().ok())
                .collect(),
            operation: lines[1].parse()?,
            test: lines[2]
                .split(" ")
                .last()
                .ok_or(anyhow!("No last element in monkey's test."))?
                .parse()?,
            when_true: lines[3]
                .split(" ")
                .last()
                .ok_or(anyhow!("No last element in monkey's test."))?
                .parse()?,
            when_false: lines[4]
                .split(" ")
                .last()
                .ok_or(anyhow!("No last element in monkey's test."))?
                .parse()?,
            business: 0,
        };
        Ok(monkey)
    }
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let mut monkeys: Vec<Monkey> = contents
        .split("\n\n")
        .filter(|x| !x.is_empty())
        .filter_map(|x| x.parse().ok())
        .collect();

    for _ in 0..20 {
        for i in 0..monkeys.len() {
            let items = monkeys[i].items.clone();
            for item in items {
                let new_worry = monkeys[i].operation.calculate(item) / 3;
                let j = if new_worry % monkeys[i].test == 0 {
                    monkeys[i].when_true
                } else {
                    monkeys[i].when_false
                };
                monkeys[j].items.push(new_worry);
                monkeys[i].business += 1;
            }
            monkeys[i].items.clear();
        }
    }

    let mut business: Vec<usize> = monkeys.iter().map(|x| x.business).collect();
    business.sort();
    business.reverse();

    println!("Solution 1: {}", business.iter().take(2).product::<usize>());

    let mut monkeys: Vec<Monkey> = contents
        .split("\n\n")
        .filter(|x| !x.is_empty())
        .filter_map(|x| x.parse().ok())
        .collect();

    let modulo: usize = monkeys.iter().map(|x| x.test).product();
    for _ in 0..10000 {
        for i in 0..monkeys.len() {
            let items = monkeys[i].items.clone();
            for item in items {
                let new_worry = monkeys[i].operation.calculate(item);
                let new_worry = new_worry % modulo;
                let j = if new_worry % monkeys[i].test == 0 {
                    monkeys[i].when_true
                } else {
                    monkeys[i].when_false
                };
                monkeys[j].items.push(new_worry);
                monkeys[i].business += 1;
            }
            monkeys[i].items.clear();
        }
    }

    let mut business: Vec<usize> = monkeys.iter().map(|x| x.business).collect();
    business.sort();
    business.reverse();

    println!("Solution 2: {}", business.iter().take(2).product::<usize>());
}
