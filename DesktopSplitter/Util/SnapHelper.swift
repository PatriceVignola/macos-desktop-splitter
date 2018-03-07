//
//  SnapHelper.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/4/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class SnapHelper {
    public enum SnapDirection {
        case None, FullScreen, Left, Right, Top, Bottom, TopLeft, TopRight, BottomLeft, BottomRight
    }
    
    static func getSnapRect(for snapDirection:SnapDirection) -> NSRect {
        // TODO: Add support for multiple screens
        // TODO: Maybe return nil instead of default NSRect()
        guard let screen = NSScreen.main?.visibleFrame else { return NSRect() }
        
        var snapRect = NSRect()
        
        switch snapDirection {
        case .FullScreen:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width, height: screen.size.height)
        case .Left:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height)
        case .Right:
            snapRect.origin = NSPoint(x: screen.minX + screen.size.width / 2, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height)
        case .Top:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width, height: screen.size.height / 2)
        case .Bottom:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY + screen.size.height / 2)
            snapRect.size = NSSize(width: screen.size.width, height: screen.size.height / 2)
        case .TopLeft:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height / 2)
        case .TopRight:
            snapRect.origin = NSPoint(x: screen.minX + screen.size.width / 2, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height / 2)
        case .BottomLeft:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY + screen.size.height / 2)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height / 2)
        case .BottomRight:
            snapRect.origin = NSPoint(x: screen.minX + screen.size.width / 2, y: screen.minY + screen.size.height / 2)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height / 2)
        default:
            break
        }
        
        return snapRect
    }
    
    static func getMirror(of snapDirection: SnapDirection) -> SnapDirection {
        switch snapDirection {
        case .None:
            return .None
        case .FullScreen:
            return .None
        case .Left:
            return .Right
        case .Right:
            return .Left
        case .Top:
            return .Bottom
        case .Bottom:
            return .Top
        case .TopLeft:
            return .BottomLeft
        case .TopRight:
            return .BottomRight
        case .BottomLeft:
            return .TopLeft
        case .BottomRight:
            return .TopRight
        }
    }
    
    static func getNextSnapDirection(fromPrevious previousSnapDirection: SnapDirection,
                                      withArrowCode arrowCode: Int) -> SnapDirection {
        var nextSnapDirection = previousSnapDirection
        
        switch arrowCode {
        case NSRightArrowFunctionKey:
            switch previousSnapDirection {
            case .None, .FullScreen, .Left, .BottomLeft, .TopLeft, .BottomRight, .TopRight, .Right:
                nextSnapDirection = .Right
            case .Bottom:
                nextSnapDirection = .BottomRight
            case .Top:
                nextSnapDirection = .TopRight
            }
        case NSLeftArrowFunctionKey:
            switch previousSnapDirection {
            case .None, .FullScreen, .Right, .BottomLeft, .TopLeft, .BottomRight, .TopRight, .Left:
                nextSnapDirection = .Left
            case .Bottom:
                nextSnapDirection = .BottomLeft
            case .Top:
                nextSnapDirection = .TopLeft
            }
        case NSUpArrowFunctionKey:
            switch previousSnapDirection {
            case .None, .Bottom, .BottomLeft, .BottomRight, .TopLeft, .TopRight, .FullScreen:
                nextSnapDirection = .Top
            case .Left:
                nextSnapDirection = .TopLeft
            case .Right:
                nextSnapDirection = .TopRight
            case .Top:
                nextSnapDirection = .FullScreen
            }
        case NSDownArrowFunctionKey:
            switch previousSnapDirection {
            case .None, .Top, .BottomLeft, .BottomRight, .TopLeft, .TopRight, .FullScreen:
                nextSnapDirection = .Bottom
            case .Left:
                nextSnapDirection = .BottomLeft
            case .Right:
                nextSnapDirection = .BottomRight
            case .Bottom:
                // TODO: Add a "Minimized" snap direction
                nextSnapDirection = .Bottom
            }
        default:
            break
        }
        
        return nextSnapDirection
    }
}
