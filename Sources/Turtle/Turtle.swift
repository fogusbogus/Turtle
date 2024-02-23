//
//  Turtle.swift
//
//  Created by Matt Hogg on 22/02/2024.
//

import Foundation
import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
open class Turtle {
	public init() {}
	public init(commands: [any TurtleCommand]) {
		self.commands = commands
	}
	private var commands: [any TurtleCommand] = []
	
	public func getPath(measure: CGFloat = 1.0) -> Path {
		var path = Path()
		let status = TurtleStatus(position: CGPoint.zero, angle: 0, penDown: false, measure: measure)
		commands.forEach { command in
			command.addToPath(path: &path, status: status)
		}
		return path
	}
	
	public func process(_ commandList: [any TurtleCommand]) {
		commands.append(contentsOf: commandList)
	}
}

@available(macOS 10.15, iOS 13.0, *)
open class TurtleStatus {
	public init(position: CGPoint, angle: CGFloat, penDown: Bool, measure: CGFloat) {
		self.position = position
		self.angle = angle
		self.penDown = penDown
		self.measure = measure
	}
	public var position: CGPoint
	public var angle: CGFloat
	public var penDown: Bool
	public var measure: CGFloat
	public var origin: CGPoint = CGPoint.zero
}

@available(macOS 10.15, iOS 13.0, *)
public protocol TurtleCommand {
	func addToPath(path: inout Path, status: TurtleStatus)
}

@available(macOS 10.15, iOS 13.0, *)
open class SetOrigin : TurtleCommand {
	
	public var point: CGPoint?
	
	public init() {}
	public init(_ x: CGFloat, _ y: CGFloat) {
		point = CGPoint(x: x, y: y)
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		status.origin = point ?? status.position
	}
}

@available(macOS 10.15, iOS 13.0, *)
open class Home : TurtleCommand {
	
	public init() {}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		MoveTo(status.origin).addToPath(path: &path, status: status)
	}
}



@available(macOS 10.15, iOS 13.0, *)
open class PenDown : TurtleCommand {
	public init() {}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		status.penDown = true
	}
}

@available(macOS 10.15, iOS 13.0, *)
open class PenUp : TurtleCommand {
	public init() {}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		status.penDown = false
	}
}

@available(macOS 10.15, iOS 13.0, *)
open class Forward: TurtleCommand {
	public var distance: CGFloat
	
	public init(_ distance: CGFloat) {
		self.distance = distance
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		let angle = status.angle / 180.0 * CGFloat.pi
		let newPos = CGPoint(x: status.position.x + distance * sin(angle), y: status.position.y + distance * cos(angle))
		let move = MoveTo(newPos)
		move.addToPath(path: &path, status: status)
	}
}

@available(macOS 10.15, iOS 13.0, *)
open class Repeat: TurtleCommand {
	public var count: Int
	public var commands: [TurtleCommand]
	
	public init(_ count: Int, _ commands: [TurtleCommand]) {
		self.count = count
		self.commands = commands
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		(0..<count).forEach { _ in
			commands.forEach { command in
				command.addToPath(path: &path, status: status)
			}
		}
	}
}

@available(macOS 10.15, iOS 13.0, *)
open class Rotate: TurtleCommand {
	public var rotation: CGFloat
	public init(_ rotation: CGFloat) {
		self.rotation = rotation
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		status.angle += rotation
		while (status.angle < 0) {
			status.angle += 360
		}
		while (status.angle >= 360) {
			status.angle -= 360
		}
	}
}

@available(macOS 10.15, iOS 13.0, *)
open class SetAngle: TurtleCommand {
	public var rotation: CGFloat
	public init(_ rotation: CGFloat) {
		self.rotation = rotation
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		status.angle = rotation
		while (status.angle < 0) {
			status.angle += 360
		}
		while (status.angle >= 360) {
			status.angle -= 360
		}
	}
}

@available(macOS 10.15, iOS 13.0, *)
open class Arc : TurtleCommand {
	public var size: CGFloat
	public var angle: CGFloat
	
	public init(_ size: CGFloat, _ angle: CGFloat) {
		self.size = size
		self.angle = angle
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		
		let repeats = angle < 0 ? -angle : angle
		let movement = size / repeats
		let rotation = angle / repeats
		
		Repeat(Int(repeats), [Rotate(rotation), Forward(movement)]).addToPath(path: &path, status: status)
	}
	
	
}

@available(macOS 10.15, iOS 13.0, *)
open class MoveTo : TurtleCommand {
	public var x: CGFloat, y: CGFloat
	public var cx: CGFloat?, cy: CGFloat?
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.x = x
		self.y = y
	}
	public init(_ x: CGFloat, _ y: CGFloat, _ cx: CGFloat, _ cy: CGFloat) {
		self.x = x
		self.y = y
		self.cx = cx
		self.cy = cy
	}
	
	public init(_ xy: CGPoint) {
		self.x = xy.x
		self.y = xy.y
	}
	public init(_ xy: CGPoint, _ cxy: CGPoint) {
		self.x = xy.x
		self.y = xy.y
		self.cx = cxy.x
		self.cy = cxy.y
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		if status.penDown {
			if let cx = cx, let cy = cy {
				path.addQuadCurve(to: CGPoint(x: x * status.measure, y: y * status.measure), control: CGPoint(x: cx * status.measure, y: cy * status.measure))
			}
			else {
				path.addLine(to: CGPoint(x: x * status.measure, y: y * status.measure))
			}
		}
		else {
			path.move(to: CGPoint(x: x * status.measure, y: y * status.measure))
		}
		status.position = CGPoint(x: x, y: y)
	}
}
