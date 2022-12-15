const std = @import("std");
const contents = @embedFile("input.txt");

const Sensor = struct { x: isize, y: isize, i: isize, j: isize };

fn parse(allocator: std.mem.Allocator) !std.ArrayList(Sensor) {
    var sensors = std.ArrayList(Sensor).init(allocator);

    var lines = std.mem.tokenize(u8, contents, "\n");
    while (lines.next()) |line| {
        var sensor = Sensor{ .x = 0, .y = 0, .i = 0, .j = 0 };
        var tokens = std.mem.tokenize(u8, line, " ");
        var i: usize = 0;
        while (tokens.next()) |token| {
            if (token[0] == 'x' or token[0] == 'y') {
                var strValue = token[2..];
                if (std.mem.endsWith(u8, token, ",") or std.mem.endsWith(u8, token, ":")) {
                    strValue = token[2 .. token.len - 1];
                }

                switch (i) {
                    0 => sensor.x = try std.fmt.parseInt(isize, strValue, 10),
                    1 => sensor.y = try std.fmt.parseInt(isize, strValue, 10),
                    2 => sensor.i = try std.fmt.parseInt(isize, strValue, 10),
                    3 => sensor.j = try std.fmt.parseInt(isize, strValue, 10),
                    else => unreachable,
                }

                i += 1;
            }
        }

        try sensors.append(sensor);
    }

    return sensors;
}

inline fn manhattan(p1: [2]isize, p2: [2]isize) usize {
    return std.math.absCast(p1[0] - p2[0]) + std.math.absCast(p1[1] - p2[1]);
}

fn sensorRegion(sensor: Sensor) [4][2]isize {
    const d = @intCast(isize, manhattan(.{ sensor.x, sensor.y }, .{ sensor.i, sensor.j }));
    return .{
        .{ sensor.x + d, sensor.y },
        .{ sensor.x, sensor.y + d },
        .{ sensor.x - d, sensor.y },
        .{ sensor.x, sensor.y - d },
    };
}

fn isPointInSensor(point: [2]isize, sensor: Sensor) bool {
    return manhattan(point, .{ sensor.x, sensor.y }) <= manhattan(.{ sensor.x, sensor.y }, .{ sensor.i, sensor.j });
}

fn isPointInSensors(point: [2]isize, sensors: *const std.ArrayList(Sensor)) bool {
    var result: bool = false;
    for (sensors.items) |sensor| {
        result = result or isPointInSensor(point, sensor);
    }
    return result;
}

fn linesIntersection(l1: [2][2]isize, l2: [2][2]isize) ![2]isize {
    const x1: i128 = l1[0][0];
    const x2: i128 = l1[1][0];
    const x3: i128 = l2[0][0];
    const x4: i128 = l2[1][0];
    const y1: i128 = l1[0][1];
    const y2: i128 = l1[1][1];
    const y3: i128 = l2[0][1];
    const y4: i128 = l2[1][1];

    const den = ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    const xNum = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4));
    const yNum = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4));

    if (den == 0) {
        return error.DivisionByZero;
    }

    const x = try std.math.divFloor(i128, xNum, den);
    const y = try std.math.divFloor(i128, yNum, den);

    return .{ @intCast(isize, x), @intCast(isize, y) };
}

fn sensorRow(sensor: Sensor, row: isize) ?[2]isize {
    const region = sensorRegion(sensor);

    const top = region[0];
    const right = region[1];
    const bottom = region[2];
    const left = region[3];

    var xs: [2]isize = .{ 0, 0 };
    var i: usize = 0;

    if (top[1] <= row and row <= right[1]) {
        const point = linesIntersection(.{ top, right }, .{ .{ top[0], row }, .{ right[0], row } }) catch null;
        if (point != null) {
            xs[i] = point.?[0];
            i += 1;
        }
    }

    if (bottom[1] <= row and row <= right[1]) {
        const point = linesIntersection(.{ bottom, right }, .{ .{ bottom[0], row }, .{ right[0], row } }) catch null;
        if (point != null) {
            xs[i] = point.?[0];
            i += 1;
        }
    }

    if (left[1] <= row and row <= top[1]) {
        const point = linesIntersection(.{ left, top }, .{ .{ left[0], row }, .{ top[0], row } }) catch null;
        if (point != null) {
            xs[i] = point.?[0];
            i += 1;
        }
    }

    if (left[1] <= row and row <= bottom[1]) {
        const point = linesIntersection(.{ left, bottom }, .{ .{ left[0], row }, .{ bottom[0], row } }) catch null;
        if (point != null) {
            xs[i] = point.?[0];
            i += 1;
        }
    }

    if (i != 2) {
        return null;
    }

    return .{ @min(xs[0], xs[1]), @max(xs[0], xs[1]) };
}

fn mergeRanges(xs: *std.ArrayList([2]isize)) !void {
    while (true) {
        var modified = false;

        blk: for (xs.items) |f, j| {
            for (xs.items) |x, i| {
                if (i == j) continue;

                if (f[0] <= x[0] and x[0] <= f[1] or
                    x[0] <= f[0] and f[0] <= x[1] or
                    f[0] <= x[1] and x[1] <= f[1] or
                    x[0] <= f[1] and f[1] <= x[1])
                {
                    const new = [_]isize{ @min(f[0], x[0]), @max(f[1], x[1]) };
                    _ = xs.swapRemove(@max(i, j));
                    _ = xs.swapRemove(@min(i, j));
                    try xs.append(new);
                    modified = true;
                    break :blk;
                }
            }
        }

        if (!modified) break;
    }
}

fn sensorLines(sensor: Sensor) [4][2][2]isize {
    var region = sensorRegion(sensor);

    const top = region[0];
    const right = region[1];
    const bottom = region[2];
    const left = region[3];

    return [4][2][2]isize{
        [2][2]isize{ top, right },
        [2][2]isize{ top, left },
        [2][2]isize{ bottom, right },
        [2][2]isize{ bottom, left },
    };
}

fn sensorsLines(allocator: std.mem.Allocator, sensors: *const std.ArrayList(Sensor)) !std.ArrayList([2][2]isize) {
    var result = std.ArrayList([2][2]isize).init(allocator);

    for (sensors.items) |sensor| {
        for (sensorLines(sensor)) |line| {
            try result.append(line);
        }
    }

    return result;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sensors = try parse(allocator);
    defer sensors.deinit();

    var rows = std.ArrayList([2]isize).init(allocator);
    defer rows.deinit();

    const row_search: isize = if (sensors.items.len > 15) 2000000 else 10;
    for (sensors.items) |sensor| {
        const row = sensorRow(sensor, row_search);
        if (row != null) {
            try rows.append(row.?);
        }
    }

    try mergeRanges(&rows);

    var count: usize = 0;

    for (rows.items) |row| {
        var k: isize = row[0];
        blk: while (k <= row[1]) : (k += 1) {
            for (sensors.items) |sensor| {
                if (sensor.y == row_search and sensor.x == k or sensor.j == row_search and sensor.i == k) {
                    continue :blk;
                }
            }

            count += 1;
        }
    }

    std.debug.print("Solution 1: {}\n", .{count});

    printTiming(timer.lap());

    const lines = try sensorsLines(allocator, &sensors);
    defer lines.deinit();

    var intersections = std.ArrayList([2]isize).init(allocator);
    defer intersections.deinit();

    const max: isize = if (sensors.items.len > 15) 4000000 else 20;

    for (lines.items) |l1, i| {
        for (lines.items) |l2, j| {
            if (i == j) continue;

            const intersection = linesIntersection(l1, l2) catch null;
            if (intersection != null) {
                if (0 <= intersection.?[0] and intersection.?[0] <= max and 0 <= intersection.?[1] and intersection.?[1] <= max) {
                    try intersections.append(intersection.?);
                }
            }
        }
    }

    var points = try std.ArrayList([2]isize).initCapacity(allocator, 8 * intersections.items.len);
    defer points.deinit();

    for (intersections.items) |intersection| {
        try points.append([2]isize{ intersection[0] + 1, intersection[1] });
        try points.append([2]isize{ intersection[0], intersection[1] + 1 });
        try points.append([2]isize{ intersection[0] - 1, intersection[1] });
        try points.append([2]isize{ intersection[0], intersection[1] - 1 });
        try points.append([2]isize{ intersection[0] + 1, intersection[1] + 1 });
        try points.append([2]isize{ intersection[0] - 1, intersection[1] - 1 });
        try points.append([2]isize{ intersection[0] - 1, intersection[1] + 1 });
        try points.append([2]isize{ intersection[0] + 1, intersection[1] - 1 });
    }

    var solutions = std.ArrayList([2]isize).init(allocator);
    defer solutions.deinit();

    blk: for (points.items) |point| {
        if (!(0 <= point[0] and point[0] <= max and 0 <= point[1] and point[1] <= max)) {
            continue;
        }

        for (solutions.items) |item| {
            if (item[0] == point[0] and item[1] == point[1]) {
                continue :blk;
            }
        }

        if (!isPointInSensors(point, &sensors)) {
            try solutions.append(point);
        }
    }

    const p = solutions.items[0];
    std.debug.print("Solution 2: {}\n", .{p[0] * 4000000 + p[1]});

    printTiming(timer.lap());
}

fn printTiming(ns: u64) void {
    var time = ns;
    const ts = [_]u8{ 'n', 'u', 'm', ' ' };
    var i: u8 = 0;

    while (i < 3 and time > 1000) {
        time /= 1000;
        i += 1;
    }

    std.debug.print("{} {c}s\n", .{ time, ts[i] });
}
