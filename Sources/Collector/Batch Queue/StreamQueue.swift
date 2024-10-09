import Foundation

struct StreamQueue<Element: Sendable> {
    var stream: AsyncStream<Element>
    let continuation: AsyncStream<Element>.Continuation?

    public init() {
        var _continuation: AsyncStream<Element>.Continuation?
        stream = AsyncStream { continuation in
            _continuation = continuation
        }
        continuation = _continuation
    }

    func push(_ event: Element) {
        continuation?.yield(event)
    }

    func cancel() {
        continuation?.finish()
    }
}
