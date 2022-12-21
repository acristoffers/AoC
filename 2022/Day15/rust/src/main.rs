use std::str::FromStr;

fn manhattan(p1: [isize; 2], p2: [isize; 2]) -> isize {
    isize::abs(p1[0] - p2[0]) + isize::abs(p1[1] - p2[1])
}

fn intersection(l1: [[isize; 2]; 2], l2: [[isize; 2]; 2]) -> Option<[isize; 2]> {
    let x1: i128 = l1[0][0] as i128;
    let x2: i128 = l1[1][0] as i128;
    let x3: i128 = l2[0][0] as i128;
    let x4: i128 = l2[1][0] as i128;
    let y1: i128 = l1[0][1] as i128;
    let y2: i128 = l1[1][1] as i128;
    let y3: i128 = l2[0][1] as i128;
    let y4: i128 = l2[1][1] as i128;

    let den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    let x_num = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4);
    let y_num = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4);

    if den == 0 {
        return None;
    }

    let x = (x_num / den) as isize;
    let y = (y_num / den) as isize;

    Some([x, y])
}

fn merge_ranges(rs: &mut Vec<[isize; 2]>) {
    loop {
        let mut modified = false;

        'blk: for (j, f) in rs.iter().enumerate() {
            for (i, x) in rs.iter().enumerate() {
                if i == j {
                    continue;
                }

                if f[0] <= x[0] && x[0] <= f[1]
                    || x[0] <= f[0] && f[0] <= x[1]
                    || f[0] <= x[1] && x[1] <= f[1]
                    || x[0] <= f[1] && f[1] <= x[1]
                {
                    let new = [f[0].min(x[0]), f[1].max(x[1])];
                    rs.remove(i.max(j));
                    rs.remove(i.min(j));
                    rs.push(new);
                    modified = true;
                    break 'blk;
                }
            }
        }

        if !modified {
            break;
        }
    }
}

#[derive(Debug)]
struct Sensor {
    x: isize,
    y: isize,
    bx: isize,
    by: isize,
}

impl Sensor {
    fn row(&self, row: isize) -> Option<[isize; 2]> {
        let [top, right, bottom, left] = self.extremeties();

        let mut xs: [isize; 2] = [0, 0];
        let mut i: usize = 0;

        if top[1] <= row && row <= right[1] {
            if let Some(point) = intersection([top, right], [[top[0], row], [right[0], row]]) {
                xs[i] = point[0];
                i += 1;
            }
        }

        if bottom[1] <= row && row <= right[1] {
            if let Some(point) = intersection([bottom, right], [[bottom[0], row], [right[0], row]])
            {
                xs[i] = point[0];
                i += 1;
            }
        }

        if left[1] <= row && row <= top[1] {
            if let Some(point) = intersection([left, top], [[left[0], row], [top[0], row]]) {
                xs[i] = point[0];
                i += 1;
            }
        }

        if left[1] <= row && row <= bottom[1] {
            if let Some(point) = intersection([left, bottom], [[left[0], row], [bottom[0], row]]) {
                xs[i] = point[0];
                i += 1;
            }
        }

        if i != 2 {
            return None;
        }

        Some([xs[0].min(xs[1]), xs[0].max(xs[1])])
    }

    fn extremeties(&self) -> [[isize; 2]; 4] {
        let d = manhattan([self.x, self.y], [self.bx, self.by]);

        [
            [self.x + d, self.y], // top
            [self.x, self.y + d], // right
            [self.x - d, self.y], // bottom
            [self.x, self.y - d], // left
        ]
    }

    fn lines(&self) -> [[[isize; 2]; 2]; 4] {
        let [top, right, bottom, left] = self.extremeties();
        [[top, right], [top, left], [bottom, right], [bottom, left]]
    }

    fn covers(&self, point: [isize; 2]) -> bool {
        manhattan([self.x, self.y], [self.bx, self.by]) >= manhattan([self.x, self.y], point)
    }
}

impl FromStr for Sensor {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let vs: Vec<isize> = s
            .split(' ')
            .filter(|c| c.starts_with('x') || c.starts_with('y'))
            .flat_map(|c| c.split('=').last())
            .map(|c| c.replace(',', ""))
            .map(|c| c.replace(':', ""))
            .flat_map(|c| c.parse())
            .collect();

        Ok(Sensor {
            x: vs[0],
            y: vs[1],
            bx: vs[2],
            by: vs[3],
        })
    }
}

fn main() {
    let contents = std::fs::read_to_string("../input.txt").expect("No input...");
    let sensors: Vec<Sensor> = contents
        .split('\n')
        .filter(|x| !x.is_empty())
        .flat_map(|s| s.parse())
        .collect();

    let mut rows: Vec<[isize; 2]> = sensors.iter().flat_map(|s| s.row(2000000)).collect();
    merge_ranges(&mut rows);

    let mut count: usize = 0;
    for rs in rows.iter().map(|r| r[0]..=r[1]) {
        'blk: for r in rs {
            for s in &sensors {
                if s.y == 2000000 && s.x == r || s.by == 2000000 && s.bx == r {
                    continue 'blk;
                }
            }
            count += 1;
        }
    }

    println!("Solution 1: {count}");

    let lines: Vec<[[isize; 2]; 2]> = sensors
        .iter()
        .map(|s| s.lines())
        .flat_map(|s| vec![s[0], s[1], s[2], s[3]])
        .collect();

    let intersections: Vec<[isize; 2]> = lines
        .iter()
        .flat_map(|l1| {
            lines
                .iter()
                .filter(|l2| l2 != &l1)
                .flat_map(|l2| intersection(*l1, *l2))
                .collect::<Vec<[isize; 2]>>()
        })
        .collect();

    let points: Vec<[isize; 2]> = intersections
        .iter()
        .flat_map(|[x, y]| {
            vec![
                [*x + 1, *y],
                [*x, *y + 1],
                [*x - 1, *y],
                [*x, *y - 1],
                [*x + 1, *y + 1],
                [*x - 1, *y - 1],
                [*x - 1, *y + 1],
                [*x + 1, *y - 1],
            ]
        })
        .filter(|[x, y]| (0..=4000000).contains(x) && (0..=4000000).contains(y))
        .collect();

    let mut uncovered: Vec<[isize; 2]> = points
        .iter()
        .filter(|p| !sensors.iter().any(|s| s.covers(**p)))
        .cloned()
        .collect();

    uncovered.dedup();

    println!(
        "Solution 2: {}",
        uncovered[0][0] * 4000000 + uncovered[0][1]
    );
}
