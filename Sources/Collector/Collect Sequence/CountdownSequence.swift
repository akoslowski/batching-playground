import Foundation

// An example for .collect(_)
struct CountdownSequence: AsyncSequence {
    typealias Element = Int

    let start: Int
    let delay: TimeInterval

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(current: start, delay: delay)
    }

    struct AsyncIterator: AsyncIteratorProtocol {
        var current: Int
        let delay: TimeInterval

        mutating func next() async -> Int? {
            guard current > 0 else { return nil }
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            defer { current -= 1 }
            return current
        }
    }
}
