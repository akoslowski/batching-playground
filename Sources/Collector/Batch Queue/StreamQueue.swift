import Foundation

/// A structure that provides an async sequence interface for streaming elements.
struct StreamQueue<Element: Sendable>: AsyncSequence {
    private let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation

    /// Initializes a new StreamQueue.
    public init(bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded) {
        let (stream, continuation) = AsyncStream<Element>.makeStream(of: Element.self, bufferingPolicy: bufferingPolicy)
        self.stream = stream
        self.continuation = continuation
    }

    /// Creates an async iterator for the stream queue.
    /// - Returns: An iterator that emits elements from the stream.
    func makeAsyncIterator() -> AsyncStream<Element>.Iterator {
        stream.makeAsyncIterator()
    }

    /// Pushes a new event into the stream queue.
    /// - Parameter event: The event to add to the stream.
    func push(_ event: Element) {
        continuation.yield(event)
    }

    /// Cancels the stream queue, stopping any further streaming.
    func cancel() {
        continuation.finish()
    }
}
