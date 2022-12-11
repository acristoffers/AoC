const std = @import("std");
const contents = @embedFile("input.txt");

pub fn main() !void {
    var i: usize = 1;
    var x: isize = 1;
    var acc: isize = 0;
    var vec = [1]u8{0} ** 240;
    var tokens = std.mem.tokenize(u8, contents, "\n");
    while (tokens.next()) |line| {
        const isNoop: u8 = if (std.mem.eql(u8, line, "noop")) 1 else 2;
        var z: u8 = 0;
        while (z < isNoop) : (z += 1) {
            if (i == 20 or i == 60 or i == 100 or i == 140 or i == 180 or i == 220) {
                acc += x * @intCast(isize, i);
            }

            if (try std.math.absInt(x - @intCast(isize, @mod(i - 1, 40))) <= 1) {
                vec[i - 1] = '#';
            } else {
                vec[i - 1] = ' ';
            }

            if (z == 1) {
                x += try std.fmt.parseInt(isize, line[5..], 10);
            }

            i += 1;
        }
    }

    std.debug.print("Solution 1: {d}\n", .{acc});
    std.debug.print("Solution 2:\n", .{});
    for (vec) |c, j| {
        std.debug.print("{c}{c}", .{ c, c });
        if (try std.math.mod(usize, j, 40) == 39) {
            std.debug.print("\n", .{});
        }
    }
}
