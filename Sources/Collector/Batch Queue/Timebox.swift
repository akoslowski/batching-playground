import Foundation

/// An actor that manages a timeout and executes an action when the timeout is reached.
actor Timebox {
    let timeout: Duration

    private var task: Task<Void, Never>?
    private let action: @Sendable () -> Void

    /// Initializes a new Timebox with a specified timeout and action.
    /// - Parameters:
    ///   - timeout: The duration to wait before executing the action.
    ///   - action: The action to execute after the timeout.
    init(timeout: Duration, action: @escaping @Sendable () -> Void) {
        self.timeout = timeout
        self.action = action
    }

    /// Resets the timeout, cancelling any existing task and starting a new one.
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
