//
//  Level.swift
//  RaycastV2
//
//  Created by Adalynn Dudney on 7/11/15.
//  Copyright © 2015 Adalynn Dudney. All rights reserved.
//

import Foundation

struct Level {
    var walls: [LineSeg]
    //Wall image
    var enemies: [Enemy]
    
    var spawn: Vector
    var exit: Rect
}

struct Enemy {
    var waypoints: [Waypoint]
    var zone: Rect //Zone that spawns enemy
    var row: Int //-1 for no row bonus
}

struct Waypoint {
    var pos: Vector
    var speed: Double //Speed to walk to waypoint
    var shots: [Shot]
}

struct Shot {
    var speed: Double //Speed to get to rotation
    var rotationDirection: Direction
    var rotation: Double //Rotation in degrees
}

enum Direction {
    case CW //Clockwise
    case CCW //Counter-Clockwise
}