import Foundation

actor Timebox {
    let timeout: Duration

    private var task: Task<Void, Never>?
    private let action: @Sendable () -> Void

    init(timeout: Duration, action: @escaping @Sendable () -> Void) {
        self.timeout = timeout
        self.action = action
    }

    func reset() async {
        task?.cancel()
        await task?.value

        task = Task { [timeout] in
            do {
                try await Task.sleep(for: timeout)
                action()
            }
            catch { /* do nothing */ }
        }
    }
}
