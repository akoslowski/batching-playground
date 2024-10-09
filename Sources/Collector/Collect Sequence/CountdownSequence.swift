import Foundation

/// An async sequence that counts down from a start value with a delay between each step.
struct CountdownSequence: AsyncSequence {
    typealias Element = Int

    let start: Int
    let delay: TimeInterval

    /// Creates an async iterator for the countdown sequence.
    /// - Returns: An iterator that emits countdown values.
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
