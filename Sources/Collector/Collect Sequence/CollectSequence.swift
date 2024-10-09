import Foundation

/// An async sequence that collects elements from an upstream sequence based on time or count.
struct CollectSequence<Upstream: AsyncSequence>: AsyncSequence {
    typealias Element = [Upstream.Element]
    typealias AsyncIterator = Iterator

    let upstream: Upstream
    let timeInterval: TimeInterval?
    let count: Int?

    /// Initializes a new CollectSequence with an upstream sequence, time interval, and count.
    /// - Parameters:
    ///   - upstream: The upstream async sequence to collect from.
    ///   - timeInterval: The time interval to collect elements.
    ///   - count: The number of elements to collect.
    init(upstream: Upstream, timeInterval: TimeInterval? = nil, count: Int? = nil) {
        self.upstream = upstream
        self.timeInterval = timeInterval
        self.count = count
    }

    /// Creates an async iterator for the collect sequence.
    /// - Returns: An iterator that emits collected elements.
    func makeAsyncIterator() -> Iterator {
        Iterator(upstream: upstream.makeAsyncIterator(), timeInterval: timeInterval, count: count)
    }

    struct Iterator: AsyncIteratorProtocol {
        var upstream: Upstream.AsyncIterator
        let timeInterval: TimeInterval?
        let count: Int?

        /// Retrieves the next batch of collected elements.
        /// - Returns: An array of collected elements or nil if the sequence is complete.
        mutating func next() async throws -> Element? {
            var collected: [Upstream.Element] = []
            let startTime = Date()

            while true {
                if let count = count, collected.count >= count {
                    return collected
                }

                if let timeInterval = timeInterval, Date().timeIntervalSince(startTime) >= timeInterval {
                    return collected.isEmpty ? nil : collected
                }

                if let element = try await upstream.next() {
                    collected.append(element)
                } else {
                    return collected.isEmpty ? nil : collected
                }
            }
        }
    }
}

extension AsyncSequence {
    /// Collects elements from the sequence based on a time interval or count.
    /// - Parameters:
    ///   - timeInterval: The time interval to collect elements.
    ///   - count: The number of elements to collect.
    /// - Returns: A CollectSequence that emits collected elements.
    func collect(every timeInterval: TimeInterval? = nil, count: Int? = nil) -> CollectSequence<Self> {
        CollectSequence(upstream: self, timeInterval: timeInterval, count: count)
    }
}
