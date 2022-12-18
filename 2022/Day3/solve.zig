const std = @import("std");
const contents = @embedFile("input.txt");

fn solution1(allocator: std.mem.Allocator) !void {
    var points: usize = 0;

    var bs1 = try std.DynamicBitSet.initEmpty(allocator, 52);
    var bs2 = try std.DynamicBitSet.initEmpty(allocator, 52);

    defer bs1.deinit();
    defer bs2.deinit();

    var lines = std.mem.tokenize(u8, contents, "\n");
    while (lines.next()) |line| {
        const x = line[0 .. line.len / 2];
        const y = line[line.len / 2 ..];

        bs1.toggleSet(bs1);
        bs2.toggleSet(bs2);

        for (x) |c| bs1.set(if (c <= 'Z') c - 'A' + 26 else c - 'a');
        for (y) |c| bs2.set(if (c <= 'Z') c - 'A' + 26 else c - 'a');

        bs1.setIntersection(bs2);
        points += bs1.findFirstSet().? + 1;
    }

    std.debug.print("Solution 1: {}\n", .{points});
}

fn solution2(allocator: std.mem.Allocator) !void {
    var points: usize = 0;

    var bs1 = try std.DynamicBitSet.initEmpty(allocator, 52);
    var bs2 = try std.DynamicBitSet.initEmpty(allocator, 52);
    var bs3 = try std.DynamicBitSet.initEmpty(allocator, 52);

    defer bs1.deinit();
    defer bs2.deinit();
    defer bs3.deinit();

    var lines = std.mem.tokenize(u8, contents, "\n");
    while (lines.next()) |line1| {
        const line2 = lines.next().?;
        const line3 = lines.next().?;

        bs1.toggleSet(bs1);
        bs2.toggleSet(bs2);
        bs3.toggleSet(bs3);

        for (line1) |c| bs1.set(if (c <= 'Z') c - 'A' + 26 else c - 'a');
        for (line2) |c| bs2.set(if (c <= 'Z') c - 'A' + 26 else c - 'a');
        for (line3) |c| bs3.set(if (c <= 'Z') c - 'A' + 26 else c - 'a');

        bs1.setIntersection(bs2);
        bs1.setIntersection(bs3);
        points += bs1.findFirstSet().? + 1;
    }

    std.debug.print("Solution 2: {}\n", .{points});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try solution1(allocator);
    try solution2(allocator);
}
