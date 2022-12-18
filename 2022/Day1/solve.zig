const std = @import("std");
const contents = @embedFile("input.txt");

pub fn main() !void {
    var max = [_]usize{ 0, 0, 0, 0 };

    var chunks = std.mem.split(u8, contents, "\n\n");
    while (chunks.next()) |chunk| {
        var sum: usize = 0;

        var lines = std.mem.tokenize(u8, chunk, "\n");
        while (lines.next()) |line| {
            sum += try std.fmt.parseInt(usize, line, 10);
        }

        max[0] = sum;
        std.sort.sort(usize, &max, {}, std.sort.asc(usize));
    }

    const vec: @Vector(3, usize) = max[1..].*;

    std.debug.print("Solution 1 is {}\n", .{max[3]});
    std.debug.print("Solution 2 is {}\n", .{@reduce(.Add, vec)});
}
