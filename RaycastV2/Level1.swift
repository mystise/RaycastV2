//
//  Level1.swift
//  RaycastV2
//
//  Created by Isaac Dudney on 7/11/15.
//  Copyright (c) 2015 Adalynn Dudney. All rights reserved.
//

import Foundation

func level1() -> Level {
    //var level = Level(size: IRect(point1: IVector(x: 0, y: 0), point2: IVector(x: 100, y: 75)), walls:[], enemies:[], spawn: IVector(x: 2, y: 2), exit: IRect(point1: IVector(x: 45, y: 45), point2: IVector(x: 50, y: 50)))
    var level = Level(size: ISize(width: 100, height: 100), walls:[], enemies:[], spawn: IVector(x: 2, y: 2), exit: IRect(point1: IVector(x: 30, y: 45), point2: IVector(x: 35, y: 50)))
    
    level.walls = [ILineSeg(point1: IVector(x: 5, y: 0), point2: IVector(x: 5, y: 10)),
                   ILineSeg(point1: IVector(x: 5, y: 10), point2: IVector(x: 15, y: 10)),
                   ILineSeg(point1: IVector(x: 5, y: 15), point2: IVector(x: 15, y: 15)),
                   ILineSeg(point1: IVector(x: 15, y: 10), point2: IVector(x: 15, y: 15)),
                   ILineSeg(point1: IVector(x: 7, y: 0), point2: IVector(x: 7, y: 25)),
                   ILineSeg(point1: IVector(x: 5, y: 15), point2: IVector(x: 5, y: 25)),
                   ILineSeg(point1: IVector(x: 5, y: 25), point2: IVector(x: 7, y: 25)),
                   ILineSeg(point1: IVector(x: 0, y: 30), point2: IVector(x: 30, y: 30)),
                   ILineSeg(point1: IVector(x: 30, y: 30), point2: IVector(x: 30, y: 10)),
                   ILineSeg(point1: IVector(x: 35, y: 10), point2: IVector(x: 25, y: 10)),
                   ILineSeg(point1: IVector(x: 35, y: 10), point2: IVector(x: 40, y: 15)),
                   ILineSeg(point1: IVector(x: 30, y: 0), point2: IVector(x: 45, y: 15)),
                   ILineSeg(point1: IVector(x: 40, y: 15), point2: IVector(x: 35, y: 20)),
                   ILineSeg(point1: IVector(x: 45, y: 15), point2: IVector(x: 40, y: 20)),
                   ILineSeg(point1: IVector(x: 35, y: 20), point2: IVector(x: 40, y: 25)),
                   ILineSeg(point1: IVector(x: 40, y: 20), point2: IVector(x: 45, y: 25)),
                   ILineSeg(point1: IVector(x: 40, y: 25), point2: IVector(x: 35, y: 30)),
                   ILineSeg(point1: IVector(x: 40, y: 20), point2: IVector(x: 30, y: 30)),
                   ILineSeg(point1: IVector(x: 35, y: 30), point2: IVector(x: 40, y: 35)),
                   ILineSeg(point1: IVector(x: 30, y: 30), point2: IVector(x: 35, y: 35)),
                   ILineSeg(point1: IVector(x: 40, y: 35), point2: IVector(x: 50, y: 35)),
                   ILineSeg(point1: IVector(x: 35, y: 35), point2: IVector(x: 25, y: 35)),
                   ILineSeg(point1: IVector(x: 25, y: 35), point2: IVector(x: 25, y: 50)),
                   ILineSeg(point1: IVector(x: 50, y: 35), point2: IVector(x: 50, y: 50)),
                   ILineSeg(point1: IVector(x: 50, y: 50), point2: IVector(x: 25, y: 50))]
    
    let waypoints: [Waypoint] = [Waypoint(pos: IVector(x: 5, y: 20),
                                 speed: 1,
                                 shots: [Shot(speed: 2,
                                         rotationDirection: .CW,
                                         rotation: 40)])]
    
    level.enemies = [Enemy(waypoints: waypoints,
                              zone: IRect(point1: IVector(x: 6, y: 21), point2: IVector(x: 8, y: 23)),
                              row: 1)]
    
    //let level = Level(size: ISize(width: 10, height: 10), walls:[], enemies:[], spawn: IVector(x: 5, y: 5), exit: IRect(point1: IVector(x: 45, y: 45), point2: IVector(x: 50, y: 50)))
    return level
}