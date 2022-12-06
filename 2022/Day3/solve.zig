const std = @import("std");

const contents = @embedFile("input.txt");

pub fn solution1() !void {
    var lines = std.mem.split(u8, contents, "\n");
    var points: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        const x = line[0 .. line.len / 2];
        const y = line[line.len / 2 ..];

        blk: for (x) |a| {
            for (y) |b| {
                if (a == b) {
                    if (a >= 'a' and a <= 'z') {
                        points += a - 'a' + 1;
                    } else {
                        points += a - 'A' + 27;
                    }
                    break :blk;
                }
            }
        }
    }

    std.log.info("Solution 1 is {}", .{points});
}

pub fn solution2() !void {
    var lines = std.mem.split(u8, contents, "\n");
    var points: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        const line2 = lines.next().?;
        const line3 = lines.next().?;

        blk: for (line) |a| {
            for (line2) |b| {
                for (line3) |c| {
                    if (a == b and b == c) {
                        if (a >= 'a' and a <= 'z') {
                            points += a - 'a' + 1;
                        } else {
                            points += a - 'A' + 27;
                        }
                        break :blk;
                    }
                }
            }
        }
    }

    std.log.info("Solution 2 is {}", .{points});
}

pub fn main() !void {
    try solution1();
    try solution2();
}
