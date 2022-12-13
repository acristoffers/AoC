const std = @import("std");
const contents = @embedFile("input.txt");

const DVec = std.ArrayList(Dyn);
const Dyn = struct {
    list: ?DVec,
    num: ?usize,

    fn wrap(self: *const Dyn, allocator: std.mem.Allocator) !Dyn {
        var item = Dyn{ .num = null, .list = DVec.init(allocator) };
        try item.list.?.append(self.*);
        return item;
    }

    fn print(self: *const Dyn) void {
        if (self.num != null) {
            std.debug.print("{}", .{self.num.?});
        } else if (self.list != null) {
            std.debug.print("(", .{});
            for (self.list.?.items) |item, i| {
                item.print();
                if (i < self.list.?.items.len - 1) {
                    std.debug.print(",", .{});
                }
            }
            std.debug.print(")", .{});
        } else {
            unreachable;
        }
    }

    fn parse(allocator: std.mem.Allocator) !Dyn {
        var tokens = std.mem.tokenize(u8, contents, "\n");
        var root = Dyn{ .num = null, .list = DVec.init(allocator) };

        var stack = std.ArrayList(*Dyn).init(allocator);
        try stack.append(&root);

        while (tokens.next()) |token| {
            var i: usize = 0;
            while (i < token.len) : (i += 1) {
                const remaining = token[i..];
                if (remaining[0] == '[') {
                    const item = Dyn{ .num = null, .list = DVec.init(allocator) };
                    var parent: *Dyn = stack.items[stack.items.len - 1];
                    try parent.list.?.append(item);
                    try stack.append(&parent.list.?.items[parent.list.?.items.len - 1]);
                } else if (remaining[0] == ']') {
                    _ = stack.pop();
                } else if (remaining[0] == ',') {
                    continue;
                } else {
                    var j: usize = 0;
                    while (remaining[j] != ']' and remaining[j] != ',') j += 1;
                    const num = try std.fmt.parseUnsigned(u8, remaining[0..j], 10);
                    try stack.items[stack.items.len - 1].list.?.append(Dyn{ .num = num, .list = null });
                    i += j - 1;
                }
            }
        }

        return root;
    }

    fn cmp(self: *const Dyn, other: *const Dyn, allocator: std.mem.Allocator) !i8 {
        if (self.num != null and other.num != null) {
            const a = self.num.?;
            const b = other.num.?;
            if (a < b) return -1;
            if (a == b) return 0;
            return 1;
        }

        if (self.num != null and other.list != null) {
            var list = try self.wrap(allocator);
            return list.cmp(other, allocator);
        }

        if (self.list != null and other.num != null) {
            var list = try other.wrap(allocator);
            return self.cmp(&list, allocator);
        }

        if (self.list.?.items.len == 0 and other.list.?.items.len != 0) return -1;
        if (self.list.?.items.len != 0 and other.list.?.items.len == 0) return 1;
        if (self.list.?.items.len == 0 and other.list.?.items.len == 0) return 0;

        var i: usize = 1;
        var v = try cmp(&self.list.?.items[0], &other.list.?.items[0], allocator);
        while (v == 0 and i < self.list.?.items.len and i < other.list.?.items.len) {
            v = try cmp(&self.list.?.items[i], &other.list.?.items[i], allocator);
            i += 1;
        }

        if (v == 0) {
            if (self.list.?.items.len > other.list.?.items.len) return 1;
            if (self.list.?.items.len < other.list.?.items.len) return -1;
        }

        return v;
    }

    fn lessThan(context: std.mem.Allocator, lhs: Dyn, rhs: Dyn) bool {
        const r = cmp(&lhs, &rhs, context) catch unreachable;
        return (r == -1);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    var elements = try Dyn.parse(allocator);

    var i: usize = 0;
    var j: usize = 0;
    while (i < elements.list.?.items.len) : (i += 2) {
        const e1 = elements.list.?.items[i];
        const e2 = elements.list.?.items[i + 1];
        const r = try e1.cmp(&e2, allocator);
        if (r == -1) {
            j += i / 2 + 1;
        }
    }
    std.debug.print("Solution 1: {}\n", .{j});

    var signal1 = Dyn{ .num = 2, .list = null };
    var signal2 = Dyn{ .num = 6, .list = null };

    signal1 = try (try signal1.wrap(allocator)).wrap(allocator);
    signal2 = try (try signal2.wrap(allocator)).wrap(allocator);

    try elements.list.?.append(signal1);
    try elements.list.?.append(signal2);

    std.sort.sort(Dyn, elements.list.?.items[0..], allocator, Dyn.lessThan);

    i = 0;
    j = 0;
    for (elements.list.?.items) |item, k| {
        if (try item.cmp(&signal1, allocator) == 0) {
            i = k + 1;
        } else if (try item.cmp(&signal2, allocator) == 0) {
            j = k + 1;
        }
    }

    std.debug.print("Solution 2: {}\n", .{i * j});
}
