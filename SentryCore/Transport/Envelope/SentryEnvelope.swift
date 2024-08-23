import Foundation

class SentryEnvelope {
    
    /**
     * The envelope header.
     */
    let header: SentryEnvelopeHeader

    /**
     * The envelope items.
     */
    let items: [SentryEnvelopeItem]
    
    init(header: SentryEnvelopeHeader, items: [SentryEnvelopeItem]) {
        self.header = header
        self.items = items
    }
}

extension SentryEnvelope : BinaryOutputStreamable {
    func stream<Target>(to target: inout Target) throws where Target : BinaryOutputStream {
        try header.stream(to: &target)
        
        try items.forEach {
            try String.newLine.stream(to: &target)
            try $0.stream(to: &target)
        }
    }
    
    convenience init<Source>(from: Source) throws where Source : BinaryInputStream {
        // Ideally we should have an SDK without this initializer.
        let data = try from.readStream()
        guard let endOfHeader = data.firstIndex(of: 0x0A),
              let headerJson = try SentrySerialization.jsonWithData(data[0..<endOfHeader]) as? [String: Any]
        else { throw SentryError("Invalid envelope header") }
        
        let header = SentryEnvelopeHeader(dictionary: headerJson)
        
        var beginIndex = data.index(after: endOfHeader)
        var items = [SentryEnvelopeItem]()
        
        while beginIndex < data.endIndex {
            guard let endOfItemHeader = data[beginIndex...].firstIndex(of: 0x0A),
                  let itemHeaderJson = try SentrySerialization.jsonWithData(data[beginIndex..<endOfItemHeader]) as? [String: Any],
                  let itemHeader = SentryEnvelopeItemHeader(dictionary: itemHeaderJson)
            else {
                throw SentryError("Corrupted envelope")
            }

            let beginOfItemData = data.index(after: endOfItemHeader)
            let endOfItemData = data.index(beginOfItemData, offsetBy: Int(itemHeader.length), limitedBy: data.endIndex) ?? data.endIndex
            let itemData = data[beginOfItemData..<endOfItemData]
            
            items.append(SentryEnvelopeItem(header: itemHeader, data: Data(itemData)))
                        
            beginIndex = data.index(after: endOfItemData)
        }
        self.init(header: header, items: items)
    }
}
