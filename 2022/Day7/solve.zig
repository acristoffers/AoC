const std = @import("std");
const contents = @embedFile("input.txt");
const NodeList = std.ArrayList(Node);
const Node = struct {
    name: []const u8,
    size: usize,
    parent: ?*Node,
    children: ?NodeList,

    fn print(self: *const Node) void {
        if (self.children != null) {
            std.debug.print("\n(\"{s}\":{d} (", .{ self.name, self.size });
            for (self.children.?.items) |child| child.print();
            std.debug.print("))", .{});
        } else {
            std.debug.print("\n\t(\"{s}\" {d})", .{ self.name, self.size });
        }
    }

    fn updateSize(self: *Node) void {
        if (self.children != null) {
            self.size = 0;
            for (self.children.?.items) |*child| {
                child.updateSize();
            }
        }
        if (self.parent != null) {
            self.parent.?.size += self.size;
        }
    }

    fn sumOfLessThan100000(self: *const Node) usize {
        if (self.children != null) {
            var size = if (self.size <= 100000) self.size else 0;
            for (self.children.?.items) |child| {
                size += child.sumOfLessThan100000();
            }
            return size;
        }
        return 0;
    }

    fn smallestLessThan(self: *const Node, size: usize) usize {
        if (self.children != null) {
            var smallest = if (self.size >= 30000000 - (70000000 - size)) self.size else @as(usize, 1e9);
            for (self.children.?.items) |child| {
                smallest = @min(smallest, child.smallestLessThan(size));
            }
            return smallest;
        }
        return 1e9;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    var root = Node{
        .name = "/",
        .size = 0,
        .parent = null,
        .children = NodeList.init(allocator),
    };

    var node = &root;

    var tokens = (std.mem.tokenize(u8, contents, "\n"));
    _ = tokens.next();
    while (tokens.next()) |line| {
        if (std.mem.startsWith(u8, line, "$")) {
            const command = line[2..4];
            switch (command[0]) {
                'c' => {
                    const name = line[5..];
                    if (std.mem.eql(u8, name, "..")) {
                        node = node.parent.?;
                    } else {
                        for (node.children.?.items) |*child| {
                            if (std.mem.eql(u8, name, child.name)) {
                                node = child;
                            }
                        }
                    }
                },
                'l' => {},
                else => unreachable,
            }
        } else {
            const child = blk: {
                if (line[0] == 'd') {
                    break :blk Node{
                        .name = line[4..],
                        .size = 0,
                        .parent = node,
                        .children = NodeList.init(allocator),
                    };
                } else {
                    var ts = std.mem.tokenize(u8, line, " ");
                    const size: []const u8 = ts.next().?;
                    const name: []const u8 = ts.next().?;
                    break :blk Node{
                        .name = name,
                        .size = try std.fmt.parseInt(usize, size, 10),
                        .parent = node,
                        .children = null,
                    };
                }
            };

            try node.children.?.append(child);
        }
    }

    root.updateSize();
    std.debug.print("Solution 1: {d}\n", .{root.sumOfLessThan100000()});
    std.debug.print("Solution 2: {d}\n", .{root.smallestLessThan(root.size)});
}
