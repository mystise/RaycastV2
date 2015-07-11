//
//  Level1.swift
//  RaycastV2
//
//  Created by Isaac Dudney on 7/11/15.
//  Copyright (c) 2015 Adalynn Dudney. All rights reserved.
//

import Foundation

func level1() -> Level {
    var level = Level(size: Rect(point1: Vector(x: 0, y: 0), point2: Vector(x: 50, y: 50)), walls:[], enemies:[], spawn: Vector(x: 5, y: 5), exit: Rect(point1: Vector(x: 45, y: 45), point2: Vector(x: 50, y: 50)))
    
    level.walls: [LineSeg] = [LineSeg(point1: Vector(x: 10, y: 10), point2: Vector(x: 15, y: 15)),
                              LineSeg(point1: Vector(x: 25, y: 25), point2: Vector(x: 30, y: 30))]
    
    let waypoints: [Waypoint] = [Waypoint(pos: Vector(x: 5, y: 20),
                                 speed: 1,
                                 shots: [Shot(speed: 2,
                                         rotationDirection: CW,
                                         rotation: 40)])]
    
    level.enemies: [Enemy] = [Enemy(waypoints: waypoints,
                              zone: Rect(point1: Vector(x: 6, y: 21) point2: Vector(x: 8, y: 23)),
                              row: 1)]
}