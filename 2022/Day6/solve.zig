const std = @import("std");

const contents = @embedFile("input.txt");

fn searchInWindow(n: usize) !usize {
    var i: usize = 0;
    while (i < contents.len) : (i += 1) {
        var found = false;

        var j: usize = i;
        while (j < i + n) : (j += 1) {
            const c = contents[j .. j + 1];
            if (std.mem.containsAtLeast(u8, contents[i .. i + n], 2, c)) {
                found = true;
                break;
            }
        }

        if (!found) {
            break;
        }
    }

    return i + n;
}

pub fn main() !void {
    const r1 = try searchInWindow(4);
    const r2 = try searchInWindow(14);
    std.log.info("Solution 1: {d}", .{r1});
    std.log.info("Solution 2: {d}", .{r2});
}
