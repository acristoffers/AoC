const std = @import("std");
const contents = @embedFile("input.txt");

const Vec = std.ArrayList;
const Pair = [2]usize;
const Point = struct {
    height: u8,
    x: usize,
    y: usize,
    f: usize,
    h: usize,
    parent: Pair,
    fn fh(self: Point) usize {
        return self.f + self.h;
    }
};

fn parse(allocator: std.mem.Allocator) !Vec(Vec(Point)) {
    var map = try Vec(Vec(Point)).initCapacity(allocator, 40);

    var lines = std.mem.tokenize(u8, contents, "\n");
    var i: usize = 0;
    while (lines.next()) |line| {
        var lineVec = try Vec(Point).initCapacity(allocator, 500);
        for (line) |c, j| {
            const point = Point{
                .height = c,
                .x = i,
                .y = j,
                .f = 0,
                .h = 0,
                .parent = Pair{ 0, 0 },
            };
            try lineVec.append(point);
        }
        try map.append(lineVec);
        i += 1;
    }

    return map;
}

fn aStar(allocator: std.mem.Allocator, forceStart: ?Pair) !usize {
    var map = try parse(allocator);
    defer map.deinit();
    defer for (map.items) |item| item.deinit();

    var open = try Vec(Pair).initCapacity(allocator, 1000);
    var closed = try Vec(Pair).initCapacity(allocator, 1000);
    var current = Pair{ 0, 0 };
    var start = Pair{ 0, 0 };
    var target = Pair{ 0, 0 };

    defer open.deinit();
    defer closed.deinit();

    for (map.items) |*line| {
        for (line.items) |*item| {
            if (item.height == 'S') {
                item.height = 'a';
                start = Pair{ item.x, item.y };
            } else if (item.height == 'E') {
                item.height = 'z';
                target = Pair{ item.x, item.y };
            }
        }
    }

    if (forceStart != null) {
        start = forceStart.?;
    }

    try open.append(start);

    while (current[0] != target[0] or current[1] != target[1]) {
        var min: usize = map.items[open.items[0][0]].items[open.items[0][1]].fh();
        var i: usize = 0;
        for (open.items) |item, j| {
            const fh = map.items[item[0]].items[item[1]].fh();
            if (min > fh) {
                min = fh;
                i = j;
            }
        }
        current = open.swapRemove(i);
        try closed.append(current);

        for ([3]i8{ -1, 0, 1 }) |x| {
            blk: for ([3]i8{ -1, 0, 1 }) |y| {
                if (std.math.absCast(x) == std.math.absCast(y)) continue;

                const nx = @intCast(isize, current[0]) + x;
                const ny = @intCast(isize, current[1]) + y;
                // Does the neighbour exist? (aka is it within bounds?)
                if (nx >= 0 and ny >= 0 and nx < map.items.len and ny < map.items[0].items.len) {
                    const neighbour = Pair{ @intCast(usize, nx), @intCast(usize, ny) };
                    var nPoint = &map.items[neighbour[0]].items[neighbour[1]];
                    const cPoint = map.items[current[0]].items[current[1]];
                    // Ok, it exists, is it at most one higher?
                    if (nPoint.height <= cPoint.height + 1) {
                        // Ok, high enough. Is it already closed?
                        for (closed.items) |item| {
                            const closedPoint = map.items[item[0]].items[item[1]];
                            if (closedPoint.x == neighbour[0] and closedPoint.y == neighbour[1]) {
                                continue :blk;
                            }
                        }

                        // Alright, not closed. Is it in open?
                        var neighbourInOpen: bool = false;
                        for (open.items) |item| {
                            const openPoint = map.items[item[0]].items[item[1]];
                            if (openPoint.x == neighbour[0] and openPoint.y == neighbour[1]) {
                                neighbourInOpen = true;
                                break;
                            }
                        }

                        // If we recalculate the neighbour's weight, is it smaller?
                        if (!(cPoint.f + 1 < nPoint.f or !neighbourInOpen)) {
                            continue :blk;
                        }

                        nPoint.f = cPoint.f + 1;
                        nPoint.h = std.math.absCast(@intCast(isize, nPoint.x) - @intCast(isize, target[0])) + std.math.absCast(@intCast(isize, nPoint.y) - @intCast(isize, target[1]));
                        nPoint.parent = Pair{ cPoint.x, cPoint.y };

                        if (!neighbourInOpen) {
                            try open.append(neighbour);
                        }
                    }
                }
            }
        }
    }

    var count: usize = 0;
    current = target;
    while (current[0] != start[0] or current[1] != start[1]) {
        count += 1;
        current = map.items[current[0]].items[current[1]].parent;
    }

    return count;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const r1 = try aStar(allocator, null);
    std.debug.print("Solution 1: {}\n", .{r1});

    var tokens = std.mem.tokenize(u8, contents, "\n");
    var numOfLines: usize = 0;
    while (tokens.next()) |_| {
        numOfLines += 1;
    }

    var min: usize = 100000;
    var i: usize = 0;
    while (i < numOfLines) : (i += 1) {
        const start = Pair{ i, 0 };
        const r2 = try aStar(allocator, start);
        min = @min(min, r2);
    }
    std.debug.print("Solution 2: {}\n", .{min});
}
