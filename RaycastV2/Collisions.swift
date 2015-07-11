//
//  Collisions.swift
//  RaycastV2
//
//  Created by Adalynn Dudney on 7/10/15.
//  Copyright © 2015 Adalynn Dudney. All rights reserved.
//

import Foundation

struct Rect: Equatable {
    var point1: Vector
    var point2: Vector
}

func ==(lhs: Rect, rhs: Rect) -> Bool {
    return lhs.point1 == rhs.point1 && lhs.point2 == rhs.point2 || lhs.point1 == rhs.point2 && lhs.point2 == rhs.point1
}

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
    
    func norm() -> Vector {
        return self / self.mag()
    }
    
    func mag() -> Double {
        return sqrt(self.mag2())
    }
    
    func mag2() -> Double {
        return self * self
    }
}

func *(lhs: Vector, rhs: Vector) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y
}

func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func *(lhs: Vector, rhs: Double) -> Vector {
    return Vector(x: lhs.x * rhs, y: lhs.y * rhs)
}

func /(lhs: Vector, rhs: Double) -> Vector {
    return Vector(x: lhs.x / rhs, y: lhs.y / rhs)
}

func +(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func +=(inout lhs: Vector, rhs: Vector) {
    lhs = lhs + rhs
}

func -=(inout lhs: Vector, rhs: Vector) {
    lhs = lhs - rhs
}

prefix func -(lhs: Vector) -> Vector {
    return Vector(x: -lhs.x, y: -lhs.y)
}

func test(line0: LineSeg, line1: LineSeg) -> Vector? {
    //Broad phase
    
    let line0MinX = min(line0.point1.x, line0.point2.x)
    let line1MaxX = max(line1.point1.x, line1.point2.x)
    
    if line0MinX >= line1MaxX {
        return nil
    }
    
    let line0MaxX = max(line0.point1.x, line0.point2.x)
    let line1MinX = min(line1.point1.x, line1.point2.x)
    
    if line0MaxX <= line1MinX {
        return nil
    }
    
    let line0MinY = min(line0.point1.y, line0.point2.y)
    let line1MaxY = max(line1.point1.y, line1.point2.y)
    
    if line0MinY >= line1MaxY {
        return nil
    }
    
    let line0MaxY = max(line0.point1.y, line0.point2.y)
    let line1MinY = min(line1.point1.y, line1.point2.y)
    
    if line0MaxY <= line1MinY {
        return nil
    }
    
    //Narrow phase
    
    let x0 = line0.point1.x
    let y0 = line0.point1.y
    let x0f = line0.point2.x
    let y0f = line0.point2.y
    let x1 = line1.point1.x
    let y1 = line1.point1.y
    let x1f = line1.point2.x
    let y1f = line1.point2.y
    
    let x0x1 = x0 - x1
    let y1y0 = y1 - y0
    let dx0 = x0f - x0
    let dy0 = y0f - y0
    let dx1 = x1f - x1
    let dy1 = y1f - y1
    
    let denom = dx1 * dy0 - dx0 * dy1
    
    if denom == 0 {
        return nil
    }
    
    let t0 = (x0x1 * dy1 + y1y0 * dx1)/denom
    let t1 = (x0x1 * dy0 + y1y0 * dx0)/denom
    
    if t0 < 0.0 || t0 > 1.0 || t1 < 0.0 || t1 > 1.0 {
        return nil
    }
    
    return Vector(x: x0 + t0 * dx0, y: y0 + t0 * dy0)
}

func test(point: Vector, rect: Rect) -> Bool {
    let rectMinX = min(rect.point1.x, rect.point2.x)
    let rectMaxX = max(rect.point1.x, rect.point2.x)
    
    if point.x > rectMaxX || point.x < rectMinX {
        return false
    }
    
    let rectMinY = min(rect.point1.y, rect.point2.y)
    let rectMaxY = max(rect.point1.y, rect.point2.y)
    
    if point.y > rectMaxY || point.y < rectMinY {
        return false
    }
    
    return true
}

func test(ray: Ray, line: LineSeg, bias: Double) -> Vector? {
    return nil
}

func test(ray: Ray, circle: Circle, bias: Double) -> Vector? {
    return nil
}

//Velocity is premultiplied with the framerate, thus the circle moves along the entire length in this function.
func handleCollision(var circle: Circle, circleVelocity: Vector, var line: LineSeg, bias: Double) -> Vector? { //If return vector exists, it's the new velocity vector. (Adjusted for collisions and sliding. Perhaps make it non-optional)
    //Broad phase
    
    /*let minLineX = min(line.point1.x, line.point2.x)
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
    }*/
    
    //Narrow phase
    
    circle.center -= line.point1
    line.point2 -= line.point1
    line.point1 = Vector(x: 0.0, y: 0.0)
    
    var lineNormal = Vector(x: line.point2.y, y: -line.point2.x).norm()
    if lineNormal * circle.center > 0.0 { //If the normal is pointing towards us, reverse it.
        lineNormal = -lineNormal
    }
    
    if lineNormal * circleVelocity < 0.0 { //If we're moving away from the wall
        return circleVelocity
    }
    
    //Projection a onto b: a dot b * b / mag(b)^2
    
    let point1 = circle.center + lineNormal * circle.radius
    
    if point1 * lineNormal > 0.0 { //If we're stuck in a wall already, and we're not moving away, cancel all movement.
        return Vector(x: 0.0, y: 0.0)
    }
    
    let line2 = LineSeg(point1: point1, point2: point1 + circleVelocity)
    
    let collision = test(line, line1: line2)
    
    if let collisionPoint = collision {
        
    } else {
        return circleVelocity
    }
    
    //Transform everything into line.point1's space
    //Take circle center, find vector to line (Take line's normal and multiply by distance to line, then re-normalize.)
    //Offset center by vector to line * radius, to find the line segment most likely to contact line. If collision is detected, find distance from final center to line, and offset by that + radius + bias. (Along the normal vector)
    //That's for the simple case of not colliding, moving towards line and colliding with it.
    
    //Other cases: Moving away from line (Should probably not modify this at all, lest other bugs cause bigger problems)
    //Moving into corner (Could cause problems where order of operations changes final location)
    //Partially colliding at beginning
    
    return nil
}