const std = @import("std");
const contents = @embedFile("test.txt");
const RndGen = std.rand.DefaultPrng;

const Node = struct {
    flowRate: usize,
    connections: std.AutoHashMap([2]u8, usize),
    active: bool,
};

fn parse(allocator: std.mem.Allocator) !std.AutoHashMap([2]u8, Node) {
    var map = std.AutoHashMap([2]u8, Node).init(allocator);
    const keywords = [_][]const u8{ "Valve", "has", "flow", "tunnel", "tunnels", "lead", "leads", "to", "valve", "valves" };
    var lines = std.mem.tokenize(u8, contents, "\n");

    while (lines.next()) |line| {
        var i: usize = 0;
        var id: [2]u8 = "ZZ".*;
        var tokens = std.mem.tokenize(u8, line, " ");
        var node = Node{
            .flowRate = 0,
            .connections = std.AutoHashMap([2]u8, usize).init(allocator),
            .active = false,
        };

        tokens: while (tokens.next()) |token| {
            for (keywords) |keyword| {
                if (std.mem.eql(u8, keyword, token)) {
                    continue :tokens;
                }
            }

            switch (i) {
                0 => id = token[0..2].*,
                1 => node.flowRate = try std.fmt.parseUnsigned(u8, token[5 .. token.len - 1], 10),
                else => {
                    try node.connections.put(token[0..2].*, 1);
                },
            }

            i += 1;
        }

        try map.put(id, node);
    }

    return map;
}

fn removeUselessValves(map: *std.AutoHashMap([2]u8, Node)) !void {
    var keyIterator = map.keyIterator();
    while (keyIterator.next()) |key| {
        var node = map.getPtr(key.*).?;

        if (node.flowRate != 0) {
            continue;
        }

        var modified: bool = true;
        while (modified) {
            modified = false;

            var connKeyIter = node.connections.keyIterator();
            while (connKeyIter.next()) |connKey| {
                const other = map.get(connKey.*).?;

                if (other.flowRate != 0 or std.mem.eql(u8, connKey, key)) {
                    continue;
                }

                const cost = node.connections.get(connKey.*).? + 1;

                if (cost > 100) {
                    _ = node.connections.remove(connKey.*);
                    modified = true;
                    break;
                }

                var connConnKeyIter = other.connections.keyIterator();
                while (connConnKeyIter.next()) |connConnKey| {
                    if (std.mem.eql(u8, connConnKey, key)) {
                        continue;
                    }

                    var entry = try node.connections.getOrPut(connConnKey.*);
                    if (!entry.found_existing) {
                        entry.value_ptr.* = cost;
                    }
                }

                _ = node.connections.remove(connKey.*);
                modified = true;
                break;
            }
        }
    }

    keyIterator = map.keyIterator();
    while (keyIterator.next()) |key| {
        var node = map.getPtr(key.*).?;

        if (node.flowRate == 0) {
            continue;
        }

        var modified: bool = true;
        while (modified) {
            modified = false;

            var connKeyIter = node.connections.keyIterator();
            while (connKeyIter.next()) |connKey| {
                const other = map.get(connKey.*).?;

                if (other.flowRate != 0) {
                    continue;
                }

                var connConnKeyIter = other.connections.keyIterator();
                while (connConnKeyIter.next()) |connConnKey| {
                    if (std.mem.eql(u8, connConnKey, key)) {
                        continue;
                    }

                    var cost = other.connections.get(connConnKey.*).? + 1;
                    var entry = try node.connections.getOrPut(connConnKey.*);
                    if (!entry.found_existing) {
                        entry.value_ptr.* = cost;
                    }
                }

                _ = node.connections.remove(connKey.*);
                modified = true;
                break;
            }
        }
    }

    keyIterator = map.keyIterator();
    while (keyIterator.next()) |key| {
        var node = map.getPtr(key.*).?;

        if (node.flowRate == 0 and !std.mem.eql(u8, key, "AA")) {
            _ = map.remove(key.*);
        }
    }
}

fn singleRandomWalk(map: std.AutoHashMap([2]u8, Node)) !usize {
    var rnd = RndGen.init(42);
    var objective: usize = 0;

    var runs: usize = 0;
    while (runs < 500_000_000) : (runs += 1) {
        var keyIterator = map.keyIterator();
        while (keyIterator.next()) |key| {
            var node = map.getPtr(key.*).?;
            node.active = false;
        }

        var node = map.getPtr("AA".*).?;
        var cost: usize = 0;
        var step: usize = 0;
        while (step < 30) {
            if (!node.active and node.flowRate > 0 and rnd.random().float(f64) > 0.7) {
                cost += (30 - step - 1) * node.flowRate;
                node.active = true;
                step += 1;
            } else {
                var keys = node.connections.keyIterator();
                const index = @floatToInt(usize, @round(@intToFloat(f64, node.connections.count() - 1) * rnd.random().float(f64)));
                const key = blk: {
                    var j: usize = 0;
                    while (j < index) : (j += 1) {
                        _ = keys.next();
                    }
                    break :blk keys.next().?;
                };
                step += node.connections.get(key.*).?;
                node = map.getPtr(key.*).?;
            }
        }

        if (cost > objective) std.debug.print("New cost: {}\n", .{cost});
        objective = @max(objective, cost);
    }

    return objective;
}

fn doubleRandomWalk(map: std.AutoHashMap([2]u8, Node)) !usize {
    var rnd = RndGen.init(42);
    var objective: usize = 0;

    // var runs: usize = 0;
    // while (runs < 500_000_000) : (runs += 1) {
    while (true) {
        var keyIterator = map.keyIterator();
        while (keyIterator.next()) |key| {
            var node = map.getPtr(key.*).?;
            node.active = false;
        }

        var myFirstNode: ?[2]u8 = null;
        var myNode = map.getPtr("AA".*).?;
        var myCost: usize = 0;
        var myStep: usize = 0;
        while (myStep < 26) {
            if (!myNode.active and myNode.flowRate > 0 and rnd.random().float(f64) > 0.7) {
                myCost += (26 - myStep - 1) * myNode.flowRate;
                myNode.active = true;
                myStep += 1;
            } else {
                var keys = myNode.connections.keyIterator();
                const index = @floatToInt(usize, @round(@intToFloat(f64, myNode.connections.count() - 1) * rnd.random().float(f64)));
                const key = blk: {
                    var j: usize = 0;
                    while (j < index) : (j += 1) {
                        _ = keys.next();
                    }
                    break :blk keys.next().?;
                };
                myStep += myNode.connections.get(key.*).?;
                myNode = map.getPtr(key.*).?;
                if (myFirstNode == null) {
                    myFirstNode = key.*;
                }
            }
        }

        var hisNode = map.getPtr("AA".*).?;
        var hisCost: usize = 0;
        var hisStep: usize = 0;
        while (hisStep < 26) {
            if (!hisNode.active and myNode.flowRate > 0 and rnd.random().float(f64) > 0.7) {
                hisCost += (26 - hisStep - 1) * hisNode.flowRate;
                hisNode.active = true;
                hisStep += 1;
            } else {
                var keys = hisNode.connections.keyIterator();
                const index = @floatToInt(usize, @round(@intToFloat(f64, hisNode.connections.count() - 1) * rnd.random().float(f64)));
                const key = blk: {
                    var j: usize = 0;
                    while (j < index) : (j += 1) {
                        _ = keys.next();
                    }
                    break :blk keys.next().?;
                };

                if (std.mem.eql(u8, &myFirstNode.?, key)) {
                    continue;
                }

                hisStep += hisNode.connections.get(key.*).?;
                hisNode = map.getPtr(key.*).?;
                myFirstNode = null;
            }
        }

        const totalCost = myCost + hisCost;

        if (totalCost > objective) std.debug.print("New cost: {}\n", .{totalCost});
        objective = @max(objective, totalCost);
    }

    return objective;
}

fn recursePath(allocator: std.mem.Allocator, nodeName: [2]u8, cost: usize, step: usize, map: std.AutoHashMap([2]u8, Node)) !usize {
    if (step == 30 or step >= 10 and cost == 0) {
        return cost;
    }

    var node = map.get(nodeName).?;
    var newCost: usize = cost;
    var newMap = try map.cloneWithAllocator(allocator);
    defer newMap.deinit();

    var keyIterator = node.connections.keyIterator();
    while (keyIterator.next()) |key| {
        var newStep = step + node.connections.get(key.*).?;
        if (newStep > 30) continue;
        var branchCost = try recursePath(allocator, key.*, cost, newStep, newMap);
        newCost = @max(newCost, branchCost);
    }

    if (!node.active and node.flowRate > 0) {
        const updatedCost = cost + (30 - step - 1) * node.flowRate;
        var newNode = newMap.getPtr(nodeName).?;
        newNode.active = true;

        keyIterator = node.connections.keyIterator();
        while (keyIterator.next()) |key| {
            var newStep = step + node.connections.get(key.*).? + 1;
            if (newStep > 30) continue;
            var branchCost = try recursePath(allocator, key.*, updatedCost, newStep, newMap);
            newCost = @max(newCost, branchCost);
        }
    }

    return newCost;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    var map: std.AutoHashMap([2]u8, Node) = try parse(allocator);
    try removeUselessValves(&map);

    var iterator = map.keyIterator();
    while (iterator.next()) |key| {
        const node = map.get(key.*).?;
        std.debug.print("{s} ({d}) -> ", .{ key, node.flowRate });
        var connKeys = node.connections.keyIterator();
        while (connKeys.next()) |connKey| {
            std.debug.print("{s}:{d} ", .{ connKey, node.connections.get(connKey.*).? });
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n\n", .{});

    // const r1 = try recursePath(gpa.allocator(), "AA".*, 0, 0, map);
    const r1 = try singleRandomWalk(map);
    const r2 = try doubleRandomWalk(map);

    std.debug.print("Solution 1: {d}\n", .{r1});
    std.debug.print("Solution 2: {d}\n", .{r2});
}
