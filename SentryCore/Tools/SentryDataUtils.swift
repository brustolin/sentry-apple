import Foundation
import Compression

class SentryDataUtils {
    static func gzipped(data: Data) -> Data? {
           guard !data.isEmpty else { return nil }

           var sourceBuffer = [UInt8](data)
           let sourceSize = sourceBuffer.count

           let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: sourceSize)
           defer { destinationBuffer.deallocate() }

           let compressedSize = compression_encode_buffer(destinationBuffer, sourceSize, &sourceBuffer, sourceSize, nil, COMPRESSION_ZLIB)

           guard compressedSize != 0 else { return nil }

           return Data(bytes: destinationBuffer, count: compressedSize)
       }
}
