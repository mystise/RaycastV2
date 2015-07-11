//
//  Collisions.swift
//  RaycastV2
//
//  Created by Adalynn Dudney on 7/10/15.
//  Copyright © 2015 Adalynn Dudney. All rights reserved.
//

import Foundation

struct Ray: Equatable {
    var pos: Vector
    var dir: Vector
}

func ==(lhs: Ray, rhs: Ray) -> Bool {
    return lhs.pos == rhs.pos && lhs.dir == rhs.dir
}

struct LineSeg: Equatable {
    var point1: Vector
    var point2: Vector
}

func ==(lhs: LineSeg, rhs: LineSeg) -> Bool {
    return lhs.point1 == rhs.point1 && lhs.point2 == rhs.point2
}

struct Circle: Equatable {
    var center: Vector
    var radius: Double
}

func ==(lhs: Circle, rhs: Circle) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}

struct Vector: Equatable {
    var x: Double
    var y: Double
}

func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func test(line0: LineSeg, line1: LineSeg) -> Vector? {
    //Broad phase
    
    let x0 = min(line0.point1.x, line0.point2.x)
    let x1f = max(line1.point1.x, line1.point2.x)
    
    if x0 >= x1f {
        return nil
    }
    
    let x0f = max(line0.point1.x, line0.point2.x)
    let x1 = min(line1.point1.x, line1.point2.x)
    
    if x0f <= x1 {
        return nil
    }
    
    let y0 = min(line0.point1.y, line0.point2.y)
    let y1f = max(line1.point1.y, line1.point2.y)
    
    if y0 >= y1f {
        return nil
    }
    
    let y0f = max(line0.point1.y, line0.point2.y)
    let y1 = min(line1.point1.y, line1.point2.y)
    
    if y0f <= y1 {
        return nil
    }
    
    //Narrow phase
    
    let x0x1 = x0 - x1
    let y1y0 = y1 - y0
    let dx0 = x0f - x0
    let dy0 = y0f - y0
    let dx1 = x1f - x1
    let dy1 = y1f - y1
    
    let t0 = (x0x1 * dy1 + y1y0 * dx1)/(dx1 * dy0 - dx0 * dy1)
    let t1 = (x0x1 * dy0 + y1y0 * dx0)/(dx1 * dy0 - dx0 * dy1)
    
    if t0 < 0.0 || t0 > 1.0 || t1 < 0.0 || t1 > 1.0 {
        return nil
    }
    
    return Vector(x: x0 + t0 * dx0, y: y0 + t0 * dy0)
}

func test(ray: Ray, line: LineSeg, bias: Double) -> Vector? {
    return nil
}

func test(ray: Ray, circle: Circle, bias: Double) -> Vector? {
    return nil
}

//Velocity is premultiplied with the framerate, thus the circle moves along the entire length in this function.
func handleCollision(circle: Circle, circleVelocity: Vector, line: LineSeg, bias: Double) -> Vector? { //If return vector exists, it's the new velocity vector. (Adjusted for collisions and sliding. Perhaps make it non-optional)
    //Broad phase
    
    let minLineX = min(line.point1.x, line.point2.x)
    let maxCircleX = circle.center.x + circle.radius
    
    if minLineX >= maxCircleX {
        return nil
    }
    
    let maxLineX = max(line.point1.x, line.point2.x)
    let minCircleX = circle.center.x - circle.radius
    
    if maxLineX <= minCircleX {
        return nil
    }
    
    let minLineY = min(line.point1.y, line.point2.y)
    let maxCircleY = circle.center.y + circle.radius
    
    if minLineY >= maxCircleY {
        return nil
    }
    
    let maxLineY = max(line.point1.y, line.point2.y)
    let minCircleY = circle.center.y - circle.radius
    
    if maxLineY <= minCircleY {
        return nil
    }
    
    //Narrow phase
    
    //Transform everything into line.point1's space
    //Take circle center, find vector to line (Take line's normal and multiply by distance to line, then re-normalize.)
    //Offset center by vector to line * radius, to find the line segment most likely to contact line. If collision is detected, find distance from final center to line, and offset by that + radius + bias. (Along the normal vector)
    //That's for the simple case of not colliding, moving towards line and colliding with it.
    
    //Other cases: Moving away from line (Should probably not modify this at all, lest other bugs cause bigger problems)
    //Moving into corner (Could cause problems where order of operations changes final location)
    //Partially colliding at beginning
    
    return nil
}