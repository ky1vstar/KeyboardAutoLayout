import Foundation

extension String {
    var base64Decoded: String {
        Data(base64Encoded: self)
            .flatMap {
                String(data: $0, encoding: .utf8)
            }
            ?? self
    }
}
