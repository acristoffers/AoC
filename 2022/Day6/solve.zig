const std = @import("std");
const contents = @embedFile("input.txt");

fn searchInWindow(n: usize) usize {
    var i: usize = 0;
    blk: while (i < contents.len) : (i += 1) {
        var j: usize = i;
        while (j < i + n) : (j += 1) {
            const c = contents[j .. j + 1];
            if (std.mem.containsAtLeast(u8, contents[i .. i + n], 2, c)) {
                continue :blk;
            }
        }
        break;
    }
    return i + n;
}

pub fn main() !void {
    const r1 = searchInWindow(4);
    const r2 = searchInWindow(14);

    std.debug.print("Solution 1: {d}\n", .{r1});
    std.debug.print("Solution 2: {d}\n", .{r2});
}
