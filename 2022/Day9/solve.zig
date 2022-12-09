const std = @import("std");
const contents = @embedFile("input.txt");
const Point = struct { x: isize, y: isize };

fn moveHead(head: Point, direction: u8) Point {
    return switch (direction) {
        'R' => Point{ .x = head.x + 1, .y = head.y },
        'L' => Point{ .x = head.x - 1, .y = head.y },
        'U' => Point{ .y = head.y + 1, .x = head.x },
        'D' => Point{ .y = head.y - 1, .x = head.x },
        else => unreachable,
    };
}

fn moveTail(head: Point, tail: Point) Point {
    const dx = head.x - tail.x;
    const dy = head.y - tail.y;
    if (dx * dx + dy * dy <= 2) return tail;
    return Point{
        .x = tail.x + std.math.sign(dx),
        .y = tail.y + std.math.sign(dy),
    };
}

fn simulate(allocator: std.mem.Allocator, comptime n: usize) !usize {
    var tokens = std.mem.tokenize(u8, contents, "\n");
    var snake: [n]Point = [1]Point{.{ .x = 0, .y = 0 }} ** n;
    var visited = std.AutoHashMap(Point, u8).init(allocator);
    defer visited.deinit();

    while (tokens.next()) |token| {
        var ts = std.mem.tokenize(u8, token, " ");
        const direction = ts.next().?[0];
        const times = try std.fmt.parseInt(u8, ts.next().?, 10);

        var i: usize = 0;
        while (i < times) : (i += 1) {
            snake[0] = moveHead(snake[0], direction);
            var j: usize = 1;
            while (j < n) : (j += 1) {
                snake[j] = moveTail(snake[j - 1], snake[j]);
            }
            try visited.put(snake[n - 1], 0);
        }
    }

    return visited.count();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const r1 = try simulate(allocator, 2);
    const r2 = try simulate(allocator, 10);

    std.debug.print("Solution 1: {d}\n", .{r1});
    std.debug.print("Solution 2: {d}\n", .{r2});
}
