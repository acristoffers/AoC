const std = @import("std");
const contents = @embedFile("input.txt");

const Point = struct {
    x: usize,
    y: usize,

    fn in(self: *const Point, ps: *const std.AutoHashMap(Point, void)) bool {
        return ps.contains(self.*);
    }
};

fn parse(allocator: std.mem.Allocator) !std.AutoHashMap(Point, void) {
    var rocks = std.AutoHashMap(Point, void).init(allocator);

    var lines = std.mem.tokenize(u8, contents, "\n");
    while (lines.next()) |line| {
        var first: bool = true;
        var points = std.mem.tokenize(u8, line, " -> ");
        var head = Point{ .x = 0, .y = 0 };
        while (points.next()) |point| {
            const tail = Point{
                .x = try std.fmt.parseUnsigned(usize, point[0..3], 10),
                .y = try std.fmt.parseUnsigned(usize, point[4..], 10),
            };

            if (first) {
                try rocks.put(tail, {});
                head = tail;
                first = false;
                continue;
            }

            var k: usize = 0;

            if (head.x < tail.x) {
                k = head.x + 1;
                while (k <= tail.x) : (k += 1) {
                    try rocks.put(Point{ .x = k, .y = head.y }, {});
                }
            } else if (head.y < tail.y) {
                k = head.y + 1;
                while (k <= tail.y) : (k += 1) {
                    try rocks.put(Point{ .x = head.x, .y = k }, {});
                }
            } else if (head.x > tail.x) {
                k = head.x - 1;
                while (k >= tail.x) : (k -= 1) {
                    try rocks.put(Point{ .x = k, .y = head.y }, {});
                }
            } else if (head.y > tail.y) {
                k = head.y - 1;
                while (k >= tail.y) : (k -= 1) {
                    try rocks.put(Point{ .x = head.x, .y = k }, {});
                }
            }

            head = tail;
        }
    }

    return rocks;
}

fn draw(rocks: *const std.AutoHashMap(Point, void), sand: *const std.AutoHashMap(Point, void), floor: bool) void {
    var minx: usize = 100000;
    var miny: usize = 100000;
    var maxx: usize = 0;
    var maxy: usize = 0;

    var keyIterator = rocks.keyIterator();
    while (keyIterator.next()) |rock| {
        minx = @min(minx, rock.x);
        miny = @min(miny, rock.y);
        maxx = @max(maxx, rock.x);
        maxy = @max(maxy, rock.y);
    }

    if (floor) maxy += 2;

    keyIterator = sand.keyIterator();
    for (keyIterator.next()) |grain| {
        minx = @min(minx, grain.x);
        miny = @min(miny, grain.y);
        maxx = @max(maxx, grain.x);
        maxy = @max(maxy, grain.y);
    }

    minx = @min(minx, 500);
    miny = @min(miny, 0);

    var j: usize = miny;
    while (j <= maxy) : (j += 1) {
        var i: usize = minx;
        while (i <= maxx) : (i += 1) {
            const p = Point{ .x = i, .y = j };
            var char: u8 = '.';
            if (p.in(rocks) or (floor and p.y == maxy)) {
                char = '#';
            } else if (p.x == 500 and p.y == 0) {
                char = '+';
            } else if (p.in(sand)) {
                char = 'O';
            }
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn fall(rocks: *const std.AutoHashMap(Point, void), sand: *const std.AutoHashMap(Point, void), hasFloor: bool) ?Point {
    var floor: usize = 0;
    var keyIterator = rocks.keyIterator();
    while (keyIterator.next()) |rock| floor = @max(floor, rock.y);
    floor += 2;

    var point = Point{ .x = 500, .y = 0 };
    while (true) {
        if (!hasFloor and point.y > floor) return null;
        if (hasFloor and point.y == floor - 1) return point;
        point.y += 1;
        if (!point.in(rocks) and !point.in(sand)) continue;
        point.x -= 1;
        if (!point.in(rocks) and !point.in(sand)) continue;
        point.x += 2;
        if (!point.in(rocks) and !point.in(sand)) continue;
        point.x -= 1;
        point.y -= 1;
        if (point.x == 500 and point.y == 0) return null;
        return point;
    }
}

fn simulate(allocator: std.mem.Allocator, rocks: *const std.AutoHashMap(Point, void), hasFloor: bool) !std.AutoHashMap(Point, void) {
    var sand = std.AutoHashMap(Point, void).init(allocator);

    var point = fall(rocks, &sand, hasFloor);
    while (point != null) {
        try sand.put(point.?, {});
        point = fall(rocks, &sand, hasFloor);
    }

    return sand;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var rocks = try parse(allocator);
    defer rocks.deinit();

    var sand = try simulate(allocator, &rocks, false);
    defer sand.deinit();

    // draw(&rocks, &sand, false);

    std.debug.print("Solution 1: {}\n", .{sand.count()});

    var sand2 = try simulate(allocator, &rocks, true);
    defer sand2.deinit();

    // draw(&rocks, &sand2, true);

    std.debug.print("Solution 2: {}\n", .{sand2.count() + 1});
}
