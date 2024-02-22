//
//  Turtle.swift
//
//  Created by Matt Hogg on 22/02/2024.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
open class Turtle {
	private var commands: [any TurtleCommand] = []
	
	func getPath(measure: CGFloat = 1.0) -> Path {
		var path = Path()
		let status = TurtleStatus(position: CGPoint.zero, angle: 0, penDown: false, measure: measure)
		commands.forEach { command in
			command.addToPath(path: &path, status: status)
		}
		return path
	}
	
	func process(_ commandList: [any TurtleCommand]) {
		commands.append(contentsOf: commandList)
	}
}

open class TurtleStatus {
	init(position: CGPoint, angle: CGFloat, penDown: Bool, measure: CGFloat) {
		self.position = position
		self.angle = angle
		self.penDown = penDown
		self.measure = measure
	}
	var position: CGPoint
	var angle: CGFloat
	var penDown: Bool
	var measure: CGFloat
}

public protocol TurtleCommand {
	@available(iOS 13.0, *)
	func addToPath(path: inout Path, status: TurtleStatus)
}

@available(iOS 13.0, *)
open class PenDown : TurtleCommand {
	init() {}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		status.penDown = true
	}
}

@available(iOS 13.0, *)
open class PenUp : TurtleCommand {
	init() {}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		status.penDown = false
	}
}

@available(iOS 13.0, *)
open class Forward: TurtleCommand {
	var distance: CGFloat
	
	init(_ distance: CGFloat) {
		self.distance = distance
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		let angle = status.angle / 180.0 * CGFloat.pi
		let newPos = CGPoint(x: status.position.x + distance * sin(angle), y: status.position.y + distance * cos(angle))
		let move = MoveTo(newPos)
		move.addToPath(path: &path, status: status)
	}
}

@available(iOS 13.0, *)
open class Repeat: TurtleCommand {
	var count: Int
	var commands: [TurtleCommand]
	
	init(_ count: Int, _ commands: [TurtleCommand]) {
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

@available(iOS 13.0, *)
open class Rotate: TurtleCommand {
	var rotation: CGFloat
	init(_ rotation: CGFloat) {
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

@available(iOS 13.0, *)
open class SetAngle: TurtleCommand {
	var rotation: CGFloat
	init(_ rotation: CGFloat) {
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

@available(iOS 13.0, *)
open class MoveTo : TurtleCommand {
	var x: CGFloat, y: CGFloat
	
	init(_ x: CGFloat, _ y: CGFloat) {
		self.x = x
		self.y = y
	}
	
	init(_ xy: CGPoint) {
		self.x = xy.x
		self.y = xy.y
	}
	
	public func addToPath(path: inout Path, status: TurtleStatus) {
		if status.penDown {
			path.addLine(to: CGPoint(x: x * status.measure, y: y * status.measure))
		}
		else {
			path.move(to: CGPoint(x: x * status.measure, y: y * status.measure))
		}
		status.position = CGPoint(x: x, y: y)
	}
}
