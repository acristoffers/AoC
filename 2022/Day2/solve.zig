const std = @import("std");

const contents = @embedFile("input.txt");

pub fn main() !void {
    var lines = std.mem.split(u8, contents, "\n");
    var points: usize = 0;
    var points2: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var xs = std.mem.split(u8, line, " ");
        const o = xs.next().?;
        const m = xs.next().?;

        if (std.mem.eql(u8, o, "A") and std.mem.eql(u8, m, "Y") or
            std.mem.eql(u8, o, "B") and std.mem.eql(u8, m, "Z") or
            std.mem.eql(u8, o, "C") and std.mem.eql(u8, m, "X"))
        {
            points += 6;
        } else if ((o[0] - 'A') == (m[0] - 'X')) {
            points += 3;
        }

        points += m[0] - 'X' + 1;

        // Start of solution 2
        var p: i8 = 0;

        if (std.mem.eql(u8, m, "X")) {
            p = @intCast(i8, o[0]) - @intCast(i8, 'A') - 1;
        } else if (std.mem.eql(u8, m, "Y")) {
            points2 += 3;
            p = @intCast(i8, o[0]) - @intCast(i8, 'A');
        } else if (std.mem.eql(u8, m, "Z")) {
            points2 += 6;
            p = @intCast(i8, o[0]) - @intCast(i8, 'A') + 1;
        }

        points2 += @intCast(usize, @mod(p, 3)) + 1;
    }

    std.log.info("Solution 1 is {}", .{points});
    std.log.info("Solution 2 is {}", .{points2});
}
