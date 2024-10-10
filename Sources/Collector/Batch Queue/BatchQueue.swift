import AsyncAlgorithms
import Foundation

/// An actor that batches elements and emits them as an async sequence.
public actor BatchQueue<Element: Sendable>: AsyncSequence {
    enum Event {
        case element(Element)
        case timeOut
    }

    private let incomingEvents: StreamQueue<Element> = .init()
    private let outgoingBatches: StreamQueue<[Element]> = .init()
    private let worker: Task<Void, Never>
    private let timer: Timebox
    private let signal: StreamQueue<Void> = .init()

    /// Initializes a new BatchQueue with a specified batch size and timeout.
    /// - Parameters:
    ///   - batchSize: The number of elements to batch before emitting.
    ///   - timeout: The duration to wait before emitting a batch, when no more elements are incoming.
    public init(batchSize: Int = 3, timeout: Duration = .seconds(1)) {
        timer = .init(timeout: timeout) { [signal] in
            signal.push(())
        }
        timer.start()

        worker = Task { [incomingEvents, outgoingBatches, signal, timer] in
            for await batch in incomingEvents.chunks(ofCount: batchSize, or: signal) {
                outgoingBatches.push(batch)
                await timer.reset()
            }
        }
    }

    /// Creates an async iterator for the batch queue.
    /// - Returns: An iterator that emits batches of elements.
    public nonisolated func makeAsyncIterator() -> AsyncStream<[Element]>.Iterator {
        outgoingBatches.makeAsyncIterator()
    }

    /// Pushes a new element into the batch queue.
    /// - Parameter element: The element to add to the queue.
    public nonisolated func push(_ element: Element) {
        incomingEvents.push(element)
    }

    /// Cancels the batch queue, stopping any further batching.
    nonisolated func cancel() {
        incomingEvents.cancel()
        outgoingBatches.cancel()
    }
}
