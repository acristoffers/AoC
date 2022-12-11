const std = @import("std");
const contents = @embedFile("test.txt");
const Vec = std.ArrayList;

const Operation = struct {
    operation: enum { Add, Mul },
    rhs: ?usize,
    lhs: ?usize,
};

const Monkey = struct {
    items: Vec(usize),
    operation: Operation,
    teste: usize,
    next: [2]usize,
    operations: usize,
};

fn parseOperation(line: []const u8) !Operation {
    var tokens = std.mem.tokenize(u8, line, " ");
    _ = tokens.next();
    _ = tokens.next();
    _ = tokens.next();
    return Operation{
        .lhs = blk: {
            const token = tokens.next().?;
            if (std.mem.eql(u8, token, "old")) {
                break :blk null;
            } else {
                break :blk try std.fmt.parseInt(u8, token, 10);
            }
        },
        .operation = if (std.mem.eql(u8, tokens.next().?, "+")) .Add else .Mul,
        .rhs = blk: {
            const token = tokens.next().?;
            if (std.mem.eql(u8, token, "old")) {
                break :blk null;
            } else {
                break :blk try std.fmt.parseInt(u8, token, 10);
            }
        },
    };
}

fn parseMonkey(allocator: std.mem.Allocator, chunk: []const u8) !Monkey {
    var line = std.mem.tokenize(u8, chunk, "\n");
    _ = line.next();
    return Monkey{
        .items = blk: {
            var tokens = std.mem.tokenize(u8, line.next().?, ":");
            _ = tokens.next().?;
            var numTokens = std.mem.tokenize(u8, tokens.next().?, ",");
            var vec = Vec(usize).init(allocator);
            while (numTokens.next()) |numStr| {
                const stripped = std.mem.trim(u8, numStr, " ");
                try vec.append(try std.fmt.parseUnsigned(u8, stripped, 10));
            }
            break :blk vec;
        },
        .operation = try parseOperation(line.next().?),
        .teste = blk: {
            var token = std.mem.tokenize(u8, line.next().?, " ");
            _ = token.next();
            _ = token.next();
            _ = token.next();
            break :blk try std.fmt.parseInt(u8, token.next().?, 10);
        },
        .next = blk: {
            const line1 = line.next().?;
            const line2 = line.next().?;
            break :blk .{
                try std.fmt.parseInt(u8, line1[line1.len - 1 ..], 10),
                try std.fmt.parseInt(u8, line2[line2.len - 1 ..], 10),
            };
        },
        .operations = 0,
    };
}

fn parseMonkeys(allocator: std.mem.Allocator) !Vec(Monkey) {
    var monkeys = try Vec(Monkey).initCapacity(allocator, 10);
    var chunks = std.mem.split(u8, contents, "\n\n");
    while (chunks.next()) |chunk| {
        const monkey = try parseMonkey(allocator, chunk);
        try monkeys.append(monkey);
    }
    return monkeys;
}

fn operate(op: Operation, value: usize) usize {
    const lhs = op.lhs orelse value;
    const rhs = op.rhs orelse value;
    return switch (op.operation) {
        .Add => lhs + rhs,
        .Mul => lhs * rhs,
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var monkeys = try parseMonkeys(allocator);

    var ops = [1]usize{0} ** 10;
    var i: usize = 0;
    while (i < 20) : (i += 1) {
        for (monkeys.items) |*monkey, j| {
            for (monkey.items.items) |worry| {
                const newWorry = operate(monkey.operation, worry) / 3;
                const nextMonkey = monkey.next[if (@mod(newWorry, monkey.teste) == 0) 0 else 1];
                try monkeys.items[nextMonkey].items.append(newWorry);
                ops[j] += 1;
            }
            monkey.items.clearRetainingCapacity();
        }
    }

    std.sort.sort(usize, &ops, {}, std.sort.desc(usize));
    const r1 = ops[0] * ops[1];
    std.debug.print("Solution 1: {}\n", .{r1});

    for (monkeys.items) |monkey| monkey.items.deinit();
    monkeys.deinit();

    monkeys = try parseMonkeys(allocator);
    defer monkeys.deinit();
    defer for (monkeys.items) |monkey| monkey.items.deinit();

    var modulo: usize = 1;
    for (monkeys.items) |monkey| {
        modulo *= monkey.teste;
    }

    ops = [1]usize{0} ** 10;
    i = 0;
    while (i < 10000) : (i += 1) {
        for (monkeys.items) |*monkey, j| {
            for (monkey.items.items) |worry| {
                const newWorry = @mod(operate(monkey.operation, worry), modulo);
                const nextMonkey = monkey.next[if (@mod(newWorry, monkey.teste) == 0) 0 else 1];
                try monkeys.items[nextMonkey].items.append(newWorry);
                ops[j] += 1;
            }
            monkey.items.clearRetainingCapacity();
        }
    }

    std.sort.sort(usize, &ops, {}, std.sort.desc(usize));
    const r2 = ops[0] * ops[1];
    std.debug.print("Solution 2: {}\n", .{r2});
}
