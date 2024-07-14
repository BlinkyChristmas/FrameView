// Copyright © 2024 Charles Kerr. All rights reserved.

import Foundation
import AppKit

class FrameEntry : NSObject {
    static override func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        var rvalue = super.keyPathsForValuesAffectingValue(forKey: key)
        if key == "frameLength" {
            rvalue.insert("document.frameLength")
        }
        else if key == "frameCount" {
            rvalue.insert("document.frameCount")
        }
        else if key == "maxFrame" {
            rvalue.insert("document.frameCount")
        }
        else if key == "maxOffset" {
            rvalue.insert("document.frameLength")
        }
        return rvalue
    }
    @objc dynamic var rowIndex:Int = 0
    @objc dynamic var frameValue:UInt8 = 0
    init(rowIndex: Int, frameValue: UInt8 ) {
        self.rowIndex = rowIndex
        self.frameValue = frameValue
    }
    override init() {
        rowIndex = 0
        frameValue = 0
        super.init()
    }
}

class LightController : NSWindowController {
    override var windowNibName: NSNib.Name? {
        return "LightDocument"
    }
    
    @IBOutlet var arrayController:NSArrayController!
    @IBOutlet var tableView:NSTableView!
    
    @objc dynamic var musicName = ""
    @objc dynamic var frameCount:String {
        return String((document as? LightDocument)?.frameCount ?? 0)
    }
    @objc dynamic var currentFrame = 0 {
        didSet{
            guard document != nil else { return }
            frameData = buildFrameData(frameNumber: currentFrame)
        }
    }
    @objc dynamic var frameLength:String {
        return String((document as? LightDocument)?.frameLength ?? 0)
    }
    @objc dynamic var frameData = [FrameEntry]()
    @objc dynamic var maxFrame:Int {
        ((document as? LightDocument)?.frameCount ?? 0 ) - 1
    }
    
    @objc dynamic var maxOffset:Int {
        ((document as? LightDocument)?.frameLength ?? 0 ) - 1
    }
    @objc dynamic var frameOffset = 0 {
        didSet {
            tableView.scrollRowToVisible(frameOffset)
        }
    }
    
    func buildFrameData(frameNumber:Int) -> [FrameEntry] {
        var rvalue = [FrameEntry]()
        guard frameNumber < (document as! LightDocument).frameCount else { return rvalue }
        for (index,entry) in (document as! LightDocument).lightData[frameNumber].enumerated() {
            rvalue.append(FrameEntry(rowIndex: index, frameValue: entry))
        }
        return rvalue
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        frameData = buildFrameData(frameNumber: self.currentFrame)
    }
}
