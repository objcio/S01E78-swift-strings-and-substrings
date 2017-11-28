import XCTest

extension Substring {
    mutating func remove(upToAndIncluding idx: Index) {
        self = self[index(after: idx)...]
    }
    
    mutating func parseField() -> Substring {
        assert(!self.isEmpty)
        switch self[startIndex] {
        case "\"":
            removeFirst()
            guard let quoteIdx = index(of: "\"") else {
                fatalError("expected quote") // todo throws
            }
            let result = prefix(upTo: quoteIdx)
            remove(upToAndIncluding: quoteIdx)
            if !isEmpty {
                let comma = removeFirst()
                assert(comma == ",") // todo throws
            }
            return result
            
        default:
            if let commaIdx = index(of: ",") {
                let result = prefix(upTo: commaIdx)
                remove(upToAndIncluding: commaIdx)
                return result
            } else {
                let result = self
                removeAll()
                return result
            }
        }
    }
}

func parse(line: Substring) -> [Substring] {
    var remainder = line
    var result: [Substring] = []
    while !remainder.isEmpty {
        result.append(remainder.parseField())
    }
    return result
}

func parse(lines: String) -> [[Substring]] {
    return lines.split(whereSeparator: { char in
        switch char {
        case "\r", "\n", "\r\n": return true
        default: return false
        }
    }).map { line in
        parse(line: line)
    }
}

class ParseCSVTests: XCTestCase {
    func testLine() {
        let line = "one,2,,three" as Substring
        XCTAssertEqual(parse(line: line), ["one", "2", "", "three"])
    }
    
    func testLineWithQuotes() {
        let line = "one,\"qu,ote\",2,,three" as Substring
        XCTAssertEqual(parse(line: line), ["one", "qu,ote", "2", "", "three"])
    }
    
    func testLines() {
        let line = "one,2,,three\nfour,five"
        XCTAssertEqual(parse(lines: line), [["one", "2", "", "three"], ["four","five"]])
    }

    func testLinesWithCRLF() {
        let line = "one,2,,three\r\nfour,five"
        XCTAssertEqual(parse(lines: line), [["one", "2", "", "three"], ["four","five"]])
    }
}





















func ==<A: Equatable>(lhs: [[A]], rhs: [[A]]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (l,r) in zip(lhs,rhs) {
        guard l == r else { return false }
    }
    return true
}


func XCTAssertEqual<T>(_ lhs: [[T]], _ rhs: [[T]], file: StaticString = #file, line: UInt = #line) where T : Equatable {
    XCTAssert(lhs == rhs, "Expected \(lhs) and \(rhs) to be equal.", file: file, line: line)
}


