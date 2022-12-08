const std = @import("std");

const contents = @embedFile("input.txt");
const lineSize = std.mem.indexOf(u8, contents, "\n").? + 1;

inline fn at(i: usize, j: usize) u8 {
    return contents[i * lineSize + j] - '0';
}

fn isVisible(i: usize, j: usize) bool {
    if (i == 0 or j == 0 or i == lineSize - 2 or j == lineSize - 2) return true;
    const v = at(i, j);
    const m = lineSize - 1;
    var blocks: bool = false;
    var k: usize = 0;
    while (k < i) : (k += 1) blocks = blocks or at(k, j) >= v;
    if (!blocks) return true;
    k = 0;
    blocks = false;
    while (k < j) : (k += 1) blocks = blocks or at(i, k) >= v;
    if (!blocks) return true;
    k = i + 1;
    blocks = false;
    while (k < m) : (k += 1) blocks = blocks or at(k, j) >= v;
    if (!blocks) return true;
    k = j + 1;
    blocks = false;
    while (k < m) : (k += 1) blocks = blocks or at(i, k) >= v;
    return !blocks;
}

fn score(i: usize, j: usize) usize {
    const v = at(i, j);
    const m = lineSize - 1;
    var leScore: usize = 0;
    var s: usize = 0;
    var k: usize = 0;
    blk: {
        if (i > 0) {
            k = i - 1;
            while (k > 0) : (k -= 1) {
                s += 1;
                if (at(k, j) >= v) break :blk;
            }
            s += 1;
        }
    }
    leScore = s;
    s = 0;
    k = i + 1;
    while (k < m) : (k += 1) {
        s += 1;
        if (at(k, j) >= v) break;
    }
    leScore *= s;
    s = 0;
    blk: {
        if (j > 0) {
            k = j - 1;
            while (k > 0) : (k -= 1) {
                s += 1;
                if (at(i, k) >= v) break :blk;
            }
            s += 1;
        }
    }
    leScore *= s;
    s = 0;
    k = j + 1;
    while (k < m) : (k += 1) {
        s += 1;
        if (at(i, k) >= v) break;
    }
    leScore *= s;
    return leScore;
}

pub fn main() !void {
    var count: usize = 0;
    var i: usize = 0;
    while (i < (lineSize - 1)) : (i += 1) {
        var j: usize = 0;
        while (j < (lineSize - 1)) : (j += 1) {
            const v: usize = if (isVisible(i, j)) 1 else 0;
            if (v == 1) count += 1;
        }
    }
    std.log.info("Solution 1: {d}", .{count});

    var leScore: usize = 0;
    i = 0;
    while (i < (lineSize - 1)) : (i += 1) {
        var j: usize = 0;
        while (j < (lineSize - 1)) : (j += 1) {
            leScore = @max(leScore, score(i, j));
        }
    }
    std.log.info("Solution 2: {d}", .{leScore});
}
