var Drone = require('drone');

var CASTLE_WIDTH = 20;
var WALL_HEIGHT = 12;
var TOWER_HEIGHT = 16;
var WINDOW_SIZE = 4;
var TOWER_RADIUS = 4;

var WALL_BLOCK = 98;   // Stone bricks
var WALL_TOP_BLOCK = 85;   // oak fence
var FLOOR_BLOCK = 5;  // Wood Planks
var WINDOW_BLOCK = 20; // Glass
var TORCH_BLOCK = 50;
var STONE_STAIRS = 109;


function buildCastle(player) {
    if (!player) player = self;
    var drone = new Drone(player);
    drone.up();
    buildWalls(drone);
    buildFloor(drone);
    buildTop(drone, 3);
    buildTowers(drone);
}

function buildWalls(drone) {
    drone.box0(WALL_BLOCK, CASTLE_WIDTH, WALL_HEIGHT, CASTLE_WIDTH);
    buildWindows(drone);
    buildDoors(drone);
}

function buildWindows(drone) {
    var windowBottom = Math.round((WALL_HEIGHT - WINDOW_SIZE) / 2);
    var windowRight = Math.round((CASTLE_WIDTH - WINDOW_SIZE) / 2);
    drone.up(windowBottom)
        .turn(3);

    for (var i = 0; i < 4; i++) {
        drone.right(windowRight)
            .box(WINDOW_BLOCK, WINDOW_SIZE, WINDOW_SIZE, 1)
            .right(CASTLE_WIDTH - windowRight - 1)
            .turn();
    }
    drone.down(windowBottom)
        .turn();
}

function buildDoors(drone) {
    var doorRight = Math.round((CASTLE_WIDTH - 2) / 2);
    drone.turn(3);
    for (var i = 0; i < 4; i++) {
        drone.right(doorRight)
            .door2()
            .right(CASTLE_WIDTH - doorRight - 1)
            .turn();
    }
    drone.turn();
}

function buildTop(drone, width) {
    drone.up(WALL_HEIGHT - 2);

    for (var i = 1; i <= width; i++) {
        drone.right()
            .fwd()
            .box0(FLOOR_BLOCK, CASTLE_WIDTH - i * 2, 1, CASTLE_WIDTH - i * 2);
    }

    drone.left(width)
        .back(width);
    drone.up().box0(WALL_TOP_BLOCK, CASTLE_WIDTH, 1, CASTLE_WIDTH);
    drone.down(WALL_HEIGHT - 1);
}

function buildTowers(drone) {
    var positions = [
        [0, 0],
        [0, CASTLE_WIDTH],
        [CASTLE_WIDTH, 0],
        [CASTLE_WIDTH, CASTLE_WIDTH]
    ];

    for (var i = 0; i < positions.length; i++) {
        drone.right(positions[i][0] - TOWER_RADIUS)
            .fwd(positions[i][1] - TOWER_RADIUS)
            .box0(WALL_BLOCK, TOWER_RADIUS * 2, TOWER_HEIGHT, TOWER_RADIUS * 2)
            .up(TOWER_HEIGHT);

        for (j = 0; j < 4; j++) {
            turret = [
                STONE_STAIRS,
                STONE_STAIRS + ':' + Drone.PLAYER_STAIRS_FACING[(drone.dir + 2) % 4]
            ];
            drone.box(blocks.brick.stone)
                .up()
                .box(TORCH_BLOCK)
                .down()
                .fwd()
                .boxa(turret, 1, 1, TOWER_RADIUS * 2 - 2)
                .fwd(TOWER_RADIUS * 2 - 2)
                .turn();
        }
        drone.left(positions[i][0] - TOWER_RADIUS)
            .back(positions[i][1] - TOWER_RADIUS)
            .down(TOWER_HEIGHT);
    }
}

function buildFloor(drone) {
    drone.down()
        .right()
        .fwd()
        .box(FLOOR_BLOCK, CASTLE_WIDTH - 2, 1, CASTLE_WIDTH - 2)
        .left()
        .back()
        .up();
}

exports.buildCastle = buildCastle;
