import Foundation

extension Data {
    var imageMediaType: String {
        var byte: UInt8 = 0
        copyBytes(to: &byte, count: 1)
        switch byte {
        case 0xFF: return "image/jpeg"
        case 0x89: return "image/png"
        case 0x47: return "image/gif"
        case 0x52: return "image/webp"
        default:   return "image/jpeg"
        }
    }
}
