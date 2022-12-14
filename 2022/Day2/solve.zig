const std = @import("std");
const contents = @embedFile("input.txt");

pub fn main() !void {
    var points1: usize = 0;
    var points2: usize = 0;

    var lines = std.mem.tokenize(u8, contents, "\n");
    while (lines.next()) |line| {
        var xs = std.mem.tokenize(u8, line, " ");
        const o = xs.next().?;
        const m = xs.next().?;

        if (std.mem.eql(u8, o, "A") and std.mem.eql(u8, m, "Y") or
            std.mem.eql(u8, o, "B") and std.mem.eql(u8, m, "Z") or
            std.mem.eql(u8, o, "C") and std.mem.eql(u8, m, "X"))
        {
            points1 += 6;
        } else if ((o[0] - 'A') == (m[0] - 'X')) {
            points1 += 3;
        }

        points1 += m[0] - 'X' + 1;

        // Start of solution 2
        points2 += (m[0] - 'X') * 3;
        const p = switch (m[0]) {
            'X' => @intCast(i8, o[0] - 'A') - 1,
            'Y' => @intCast(i8, o[0] - 'A'),
            'Z' => @intCast(i8, o[0] - 'A') + 1,
            else => unreachable,
        };
        points2 += @intCast(usize, @mod(p, 3)) + 1;
    }

    std.debug.print("Solution 1 is {}\n", .{points1});
    std.debug.print("Solution 2 is {}\n", .{points2});
}
