// 

import Cocoa

class LightDocument: NSDocument {
    static let headerSize = 54
    static let signature = Int32(0x5448474c)

    typealias LightFrame = [UInt8]
    var dataOffset = 54
    @objc dynamic var musicName = ""
    @objc dynamic var frameCount = 0
    @objc dynamic var frameLength = 0
    @objc dynamic var lightData = [LightFrame]()
    @objc dynamic var framePeriod = 37

    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        self.addWindowController(LightController())
    }
    override func data(ofType typeName: String) throws -> Data {
        Swift.print("type is \(typeName)")
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        guard typeName == "com.blinky.lightfile" else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        guard data.count >= LightFile.headerSize else {
            throw NSError(domain: "Sequencer", code: 0, userInfo: [NSLocalizedDescriptionKey:"Invalid light file, insufficient size \(data.count) for header, expected \(LightDocument.headerSize)"])
        }
        let signature = data.withUnsafeBytes { $0.load(fromByteOffset: 0, as: Int32.self)}
        guard signature == LightDocument.signature else {
            throw NSError(domain: "Sequencer", code: 0, userInfo: [NSLocalizedDescriptionKey:"Invalid light file, invalid signature \(String(format:"%x",signature)) expected: \(String(format:"%x",LightFile.signature))"])
        }
        let version = data.withUnsafeBytes { $0.load(fromByteOffset: 4, as: Int32.self)}
        guard version == 0 else {
            throw NSError(domain: "Sequencer", code: 0, userInfo: [NSLocalizedDescriptionKey:"Invalid light file, invalid version \(version) expected: 0 "])
        }
        dataOffset = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 8, as: Int32.self)})
        framePeriod = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 12, as: Int32.self)})
        frameCount = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 16, as: Int32.self)})
        frameLength = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 20, as: Int32.self)})
        var temp = String(data: data[data.startIndex+24..<data.startIndex+54], encoding: .ascii)
        if temp != nil {
            temp = temp!.trimmingCharacters(in: .whitespacesAndNewlines)
            musicName = temp!
        }

        guard data.count >= frameCount * frameLength + LightFile.headerSize else {
            throw NSError(domain: "Sequencer", code: 0, userInfo: [NSLocalizedDescriptionKey:"Corrupted light file, size \(data.count) is insufficent for stated framelength * framecount + headerSize: \(frameCount * frameLength + LightFile.headerSize)"])
        }
        for frame in 0..<frameCount {
            lightData.append([UInt8](Data(data[dataOffset+frame*frameLength..<dataOffset+(frame+1)*frameLength])))
        }
        
    }


}

