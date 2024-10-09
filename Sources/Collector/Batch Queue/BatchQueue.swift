import Foundation

public actor BatchQueue<Element: Sendable>: AsyncSequence {

    enum Event {
        case element(Element)
        case timeOut
    }

    private let incomingEvents: StreamQueue<Event> = .init()
    private let outgoingBatches: StreamQueue<[Element]> = .init()
    private let worker: Task<Void, Never>
    private let timer: Timebox

    public init(batchSize: Int = 3, timeout: Duration = .seconds(1)) {
        timer = .init(timeout: timeout) { [incomingEvents] in
            incomingEvents.push(.timeOut)
        }

        worker = Task { [incomingEvents, outgoingBatches, batchSize, timer] in
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

    public nonisolated func makeAsyncIterator() -> AsyncStream<[Element]>.Iterator {
        outgoingBatches.makeAsyncIterator()
    }

    public nonisolated func push(_ element: Element) {
        incomingEvents.push(.element(element))
    }

    nonisolated func cancel() {
        incomingEvents.cancel()
        outgoingBatches.cancel()
    }
}
