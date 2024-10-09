import Foundation

struct StreamQueue<Element: Sendable>: AsyncSequence {
    private let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation?

    public init() {
        var _continuation: AsyncStream<Element>.Continuation?
        stream = AsyncStream { continuation in
            _continuation = continuation
        }
        continuation = _continuation
    }

    func makeAsyncIterator() -> AsyncStream<Element>.Iterator {
        stream.makeAsyncIterator()
    }

    func push(_ event: Element) {
        continuation?.yield(event)
    }

    func cancel() {
        continuation?.finish()
    }
}
