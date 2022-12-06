const std = @import("std");

const contents = @embedFile("input.txt");

pub fn main() !void {
    var lines = std.mem.split(u8, contents, "\n");
    var count1: usize = 0;
    var count2: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var tokens = std.mem.tokenize(u8, line, ",-");
        const r1s = try std.fmt.parseInt(usize, tokens.next().?, 10);
        const r1e = try std.fmt.parseInt(usize, tokens.next().?, 10);
        const r2s = try std.fmt.parseInt(usize, tokens.next().?, 10);
        const r2e = try std.fmt.parseInt(usize, tokens.next().?, 10);

        if (r1s >= r2s and r1e <= r2e or
            r2s >= r1s and r2e <= r1e)
        {
            count1 += 1;
        }

        if (r1s <= r2s and r1e >= r2s or
            r2s <= r1s and r2e >= r1s or
            r1s <= r2e and r1e >= r2s or
            r2s <= r1e and r2e >= r1s)
        {
            count2 += 1;
        }
    }

    std.log.info("Solution 1 is {}", .{count1});
    std.log.info("Solution 2 is {}", .{count2});
}
