const std = @import("std");

const contents = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var splits = std.mem.split(u8, contents, "\n\n");
    var max = std.ArrayList(usize).init(allocator);
    defer max.deinit();

    while (splits.next()) |chunk| {
        var subsplit = std.mem.split(u8, chunk, "\n");
        var sum: u64 = 0;

        while (subsplit.next()) |num_str| {
            if (num_str.len == 0) continue;
            sum += try std.fmt.parseInt(u64, num_str, 10);
        }

        try max.append(sum);
    }

    std.sort.sort(usize, max.items, {}, std.sort.desc(usize));

    std.log.info("Solution 1 is {}", .{max.items[0]});
    std.log.info("Solution 2 is {}", .{max.items[0] + max.items[1] + max.items[2]});
}
