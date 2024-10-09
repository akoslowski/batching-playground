import Foundation


struct Streamer<Element: Sendable> {
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

public actor BatchQueue {
    enum Event {
        case element(String)
        case timeOut
    }

    private let incomingEvents: Streamer<Event> = .init()
    private let outgoingBatches: Streamer<[String]> = .init()
    private let worker: Task<Void, Never>
    private var timer: Task<Void, Never>?

    let batchSize: Int = 3
    let timeout: Duration = .milliseconds(100)

    public var values: AsyncStream<[String]> {
        outgoingBatches.stream
    }

    public func cancel() {
        incomingEvents.cancel()
        outgoingBatches.cancel()
        timer?.cancel()
    }

    public func push(_ event: String) async {
        await resetTimer()
        incomingEvents.push(.element(event))
    }

    private func resetTimer() async {
        timer?.cancel()
        await timer?.value
        timer = Task { [incomingEvents] in
            do {
                try await Task.sleep(for: timeout)
                incomingEvents.push(.timeOut)
            } catch {
                print("Timer reset due to incoming event")
                // Timer was cancelled, do nothing
            }
        }
    }

    public init() {
        worker = Task { [incomingEvents, outgoingBatches, batchSize] in
            var batch: [String] = []

            for await event in incomingEvents.stream {
                switch event {
                case .element(let element):
                    if batch.count < batchSize {
                        batch.append(element)
                    } else {
                        outgoingBatches.push(batch)
                        batch = [element]
                    }
                case .timeOut:
                    if batch.isEmpty == false {
                        outgoingBatches.push(batch)
                        batch = []
                    }
                }
            }
        }
    }
}
