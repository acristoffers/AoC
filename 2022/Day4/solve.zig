const std = @import("std");
const contents = @embedFile("input.txt");

pub fn main() !void {
    var count1: usize = 0;
    var count2: usize = 0;

    var lines = std.mem.tokenize(u8, contents, "\n");
    while (lines.next()) |line| {
        var tokens = std.mem.tokenize(u8, line, ",-");
        const r1s = try std.fmt.parseInt(usize, tokens.next().?, 10);
        const r1e = try std.fmt.parseInt(usize, tokens.next().?, 10);
        const r2s = try std.fmt.parseInt(usize, tokens.next().?, 10);
        const r2e = try std.fmt.parseInt(usize, tokens.next().?, 10);

        if (r1s >= r2s and r1e <= r2e or
            r2s >= r1s and r2e <= r1e)
            count1 += 1;

        if (r1s <= r2s and r1e >= r2s or
            r2s <= r1s and r2e >= r1s or
            r1s <= r2e and r1e >= r2s or
            r2s <= r1e and r2e >= r1s)
            count2 += 1;
    }

    std.debug.print("Solution 1: {}\n", .{count1});
    std.debug.print("Solution 2: {}\n", .{count2});
}
