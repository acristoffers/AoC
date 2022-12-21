#![feature(iter_array_chunks)]

use std::cmp::Ordering;
use std::str::FromStr;

#[derive(Debug, Clone)]
enum Value {
    List(List),
    Number(usize),
}

#[derive(Debug, Clone)]
struct List {
    children: Vec<Value>,
}

impl List {
    fn compare(&self, other: &Self) -> Ordering {
        for (c, o) in self.children.iter().zip(other.children.iter()) {
            match (c, o) {
                (Value::List(cl), Value::List(ol)) => {
                    let r = cl.compare(ol);
                    if !r.is_eq() {
                        return r;
                    }
                }
                (Value::List(cl), Value::Number(on)) => {
                    let l = List {
                        children: vec![Value::Number(*on)],
                    };
                    let r = cl.compare(&l);
                    if !r.is_eq() {
                        return r;
                    }
                }
                (Value::Number(cn), Value::List(ol)) => {
                    let l = List {
                        children: vec![Value::Number(*cn)],
                    };
                    let r = l.compare(ol);
                    if !r.is_eq() {
                        return r;
                    }
                }
                (Value::Number(cn), Value::Number(on)) => {
                    if cn != on {
                        return cn.cmp(on);
                    }
                }
            }
        }

        self.children.len().cmp(&other.children.len())
    }
}

impl FromStr for Value {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut stack: Vec<List> = vec![];
        let mut number: String = "".into();
        let mut current = List { children: vec![] };

        for c in s.chars() {
            match c {
                '0'..='9' => number = format!("{number}{c}"),
                ',' => {
                    if !number.is_empty() {
                        let num = number.parse().expect("Cannot parse number.");
                        current.children.push(Value::Number(num));
                        number.clear();
                    }
                }
                ']' => {
                    if !number.is_empty() {
                        let num = number.parse().expect("Cannot parse number.");
                        current.children.push(Value::Number(num));
                        number.clear();
                    }
                    let mut parent = stack.pop().expect("Empty stack.");
                    parent.children.push(Value::List(current));
                    current = parent;
                }
                '[' => {
                    stack.push(current);
                    current = List { children: vec![] };
                }
                _ => panic!("Unknown token."),
            }
        }

        Ok(current.children[0].clone())
    }
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input.");
    let mut vectors: Vec<List> = contents
        .split('\n')
        .filter(|x| !x.is_empty())
        .flat_map(|s| s.parse::<Value>())
        .flat_map(|v| match v {
            Value::List(l) => Some(l),
            _ => None,
        })
        .collect();

    let r1: usize = vectors
        .iter()
        .array_chunks()
        .map(|[a, b]| a.compare(b))
        .enumerate()
        .filter(|(_, a)| a.is_lt())
        .map(|(i, _)| i + 1)
        .sum();

    println!("Solution 1: {r1}");

    let v2;
    if let Value::List(l) = "[[2]]".parse::<Value>().unwrap() {
        v2 = l.clone();
        vectors.push(l);
    } else {
        panic!("Impossibru")
    }

    let v6;
    if let Value::List(l) = "[[6]]".parse::<Value>().unwrap() {
        v6 = l.clone();
        vectors.push(l);
    } else {
        panic!("Impossibru")
    }

    vectors.sort_by(|a, b| a.compare(b));

    let r2: usize = vectors
        .iter()
        .enumerate()
        .filter(|(_, e)| e.compare(&v2).is_eq() || e.compare(&v6).is_eq())
        .map(|(i, _)| i + 1)
        .product();

    println!("Solution 2: {r2}");
}
