const std = @import("std");

const contents = @embedFile("input.txt");

pub fn main() !void {
    var splits = std.mem.split(u8, contents, "\n\n");
    var max: u64 = 0;
    var max2: u64 = 0;
    var max3: u64 = 0;

    while (splits.next()) |chunk| {
        var subsplit = std.mem.split(u8, chunk, "\n");
        var sum: u64 = 0;

        while (subsplit.next()) |num_str| {
            if (num_str.len == 0) {
                continue;
            }

            sum += try std.fmt.parseInt(u64, num_str, 10);
        }

        if (sum > max) {
            max3 = max2;
            max2 = max;
            max = sum;
        } else if (sum > max2) {
            max3 = max2;
            max2 = sum;
        } else if (sum > max3) {
            max3 = sum;
        }
    }

    std.log.info("Solution 1 is {}", .{max});
    std.log.info("Solution 2 is {}", .{max + max2 + max3});
}
