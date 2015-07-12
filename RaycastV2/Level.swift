//
//  Level.swift
//  RaycastV2
//
//  Created by Adalynn Dudney on 7/11/15.
//  Copyright © 2015 Adalynn Dudney. All rights reserved.
//

import Foundation

struct IRect {
    var point1: IVector
    var point2: IVector
}

struct ISize {
    var width: Int
    var height: Int
}

struct ILineSeg {
    var point1: IVector
    var point2: IVector
}

struct IVector {
    var x: Int
    var y: Int
}

struct Level {
    var size: ISize
    var walls: [ILineSeg]
    //Wall image
    var enemies: [Enemy]
    
    var spawn: IVector
    var exit: IRect
}

struct Enemy {
    var waypoints: [Waypoint]
    var zone: IRect //Zone that spawns enemy
    var row: Int //-1 for no row bonus
}

struct Waypoint {
    var pos: IVector
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