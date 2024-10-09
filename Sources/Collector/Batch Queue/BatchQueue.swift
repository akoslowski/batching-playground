import Foundation

/// An actor that batches elements and emits them as an async sequence.
public actor BatchQueue<Element: Sendable>: AsyncSequence {

    enum Event {
        case element(Element)
        case timeOut
    }

    private let incomingEvents: StreamQueue<Event> = .init()
    private let outgoingBatches: StreamQueue<[Element]> = .init()
    private let worker: Task<Void, Never>
    private let timer: Timebox

    /// Initializes a new BatchQueue with a specified batch size and timeout.
    /// - Parameters:
    ///   - batchSize: The number of elements to batch before emitting.
    ///   - timeout: The duration to wait before emitting a batch, when no more elements are incoming.
    public init(batchSize: Int = 3, timeout: Duration = .seconds(1)) {
        timer = .init(timeout: timeout) { [incomingEvents] in
            incomingEvents.push(.timeOut)
        }

        worker = Task { [incomingEvents, outgoingBatches, timer] in
            var batch: [Element] = []

            for await event in incomingEvents {
                switch event {
                case .element(let element):
                    batch.append(element)

                    if batch.count == batchSize {
                        outgoingBatches.push(batch)
                        batch = []
                    }

                case .timeOut:
                    if batch.isEmpty == false {
                        outgoingBatches.push(batch)
                        batch = []
                    }
                }

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
        incomingEvents.push(.element(element))
    }

    /// Cancels the batch queue, stopping any further batching.
    nonisolated func cancel() {
        incomingEvents.cancel()
        outgoingBatches.cancel()
    }
}
