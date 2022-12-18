const std = @import("std");
const contents = @embedFile("input.txt");
const Stacks = [10]std.ArrayList(u8);

fn parseCranes(allocator: std.mem.Allocator, input: []const u8) !Stacks {
    var stacks: Stacks = undefined;
    for (stacks) |*v| {
        v.* = std.ArrayList(u8).init(allocator);
    }

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        if (line[1] == '1') {
            continue;
        }

        var i: usize = 0;
        while (i < line.len) : (i += 4) {
            const token = line[i .. i + 3];
            if (token[1] != ' ') {
                const j = i / 4 + 1;
                try stacks[j].insert(0, token[1]);
            }
        }
    }

    return stacks;
}

fn move(stacks: *Stacks, input: []const u8) !void {
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");
        _ = tokens.next();
        const n = try std.fmt.parseInt(usize, tokens.next().?, 10);
        _ = tokens.next();
        const from = try std.fmt.parseInt(usize, tokens.next().?, 10);
        _ = tokens.next();
        const to = try std.fmt.parseInt(usize, tokens.next().?, 10);

        var i: usize = 0;
        while (i < n) : (i += 1) {
            try stacks[to].append(stacks[from].pop());
        }
    }
}

fn move9001(stacks: *Stacks, input: []const u8) !void {
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");
        _ = tokens.next();
        const n = try std.fmt.parseInt(usize, tokens.next().?, 10);
        _ = tokens.next();
        const from = try std.fmt.parseInt(usize, tokens.next().?, 10);
        _ = tokens.next();
        const to = try std.fmt.parseInt(usize, tokens.next().?, 10);

        try stacks[to].appendSlice(stacks[from].items[stacks[from].items.len - n ..]);

        var i: usize = 0;
        while (i < n) : (i += 1) {
            _ = stacks[from].pop();
        }
    }
}

fn main9000() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lines = std.mem.split(u8, contents, "\n\n");
    const cranes = lines.next().?;
    const moves = lines.next().?;

    var stacks = try parseCranes(allocator, cranes);
    defer for (stacks) |stack| stack.deinit();

    try move(&stacks, moves);

    var top = std.ArrayList(u8).init(allocator);
    defer top.deinit();

    for (stacks) |s| {
        if (s.items.len == 0) {
            continue;
        }

        try top.append(s.items[s.items.len - 1]);
    }

    std.debug.print("Solution 1: {s}\n", .{top.items});
}

fn main9001() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lines = std.mem.split(u8, contents, "\n\n");
    const cranes = lines.next().?;
    const moves = lines.next().?;

    var stacks = try parseCranes(allocator, cranes);
    defer for (stacks) |stack| stack.deinit();

    try move9001(&stacks, moves);

    var top = std.ArrayList(u8).init(allocator);
    defer top.deinit();

    for (stacks) |s| {
        if (s.items.len == 0) {
            continue;
        }

        try top.append(s.items[s.items.len - 1]);
    }

    std.debug.print("Solution 2: {s}\n", .{top.items});
}

pub fn main() !void {
    try main9000();
    try main9001();
}
