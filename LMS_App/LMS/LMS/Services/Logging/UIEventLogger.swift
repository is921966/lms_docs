import SwiftUI

// MARK: - UI Event Logger
class UIEventLogger {
    static let shared = UIEventLogger()
    private let logger = ComprehensiveLogger.shared
    
    private init() {}
    
    // MARK: - Button Actions
    func logButtonTap(_ buttonName: String, 
                      in view: String,
                      details: [String: Any] = [:]) {
        var eventDetails = details
        eventDetails["buttonName"] = buttonName
        eventDetails["viewName"] = view
        eventDetails["timestamp"] = Date().timeIntervalSince1970
        
        logger.logUIEvent("Button Tap", view: view, action: "tap", details: eventDetails)
    }
    
    // MARK: - Text Input
    func logTextInput(_ fieldName: String,
                      oldValue: String,
                      newValue: String,
                      in view: String) {
        logger.logUIEvent("Text Input", view: view, action: "input", details: [
            "fieldName": fieldName,
            "oldValue": oldValue,
            "newValue": newValue,
            "charactersAdded": newValue.count - oldValue.count
        ])
    }
    
    // MARK: - List/Table Actions
    func logListItemTap(_ item: String,
                        index: Int,
                        in view: String,
                        details: [String: Any] = [:]) {
        var eventDetails = details
        eventDetails["item"] = item
        eventDetails["index"] = index
        
        logger.logUIEvent("List Item Tap", view: view, action: "select", details: eventDetails)
    }
    
    func logSwipeAction(_ action: String,
                        on item: String,
                        in view: String) {
        logger.logUIEvent("Swipe Action", view: view, action: action, details: [
            "item": item,
            "gesture": "swipe"
        ])
    }
    
    // MARK: - View State
    func logViewState(_ view: String,
                      state: [String: Any]) {
        logger.logUIEvent("View State", view: view, action: "state_capture", details: state)
    }
    
    // MARK: - Alerts & Sheets
    func logAlert(_ title: String,
                  message: String,
                  actions: [String],
                  selectedAction: String? = nil) {
        logger.logUIEvent("Alert", view: "Alert", action: selectedAction ?? "shown", details: [
            "title": title,
            "message": message,
            "availableActions": actions,
            "selectedAction": selectedAction ?? "none"
        ])
    }
    
    func logSheet(_ name: String,
                  action: String,
                  in view: String) {
        logger.logUIEvent("Sheet", view: view, action: action, details: [
            "sheetName": name
        ])
    }
    
    // MARK: - Gestures
    func logGesture(_ type: String,
                    location: CGPoint? = nil,
                    in view: String) {
        var details: [String: Any] = ["gestureType": type]
        if let location = location {
            details["x"] = location.x
            details["y"] = location.y
        }
        
        logger.logUIEvent("Gesture", view: view, action: type, details: details)
    }
    
    // MARK: - Loading States
    func logLoadingState(_ isLoading: Bool,
                         in view: String,
                         reason: String? = nil) {
        logger.logUIEvent("Loading State", view: view, action: isLoading ? "start" : "end", details: [
            "isLoading": isLoading,
            "reason": reason ?? "unspecified"
        ])
    }
    
    // MARK: - Error States
    func logErrorState(_ error: Error,
                       in view: String,
                       context: [String: Any] = [:]) {
        var details = context
        details["error"] = error.localizedDescription
        details["errorType"] = String(describing: type(of: error))
        
        logger.logUIEvent("Error State", view: view, action: "error", details: details)
    }
}

// MARK: - SwiftUI View Modifiers for Logging

struct LoggableButton: ViewModifier {
    let name: String
    let view: String
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content.onTapGesture {
            UIEventLogger.shared.logButtonTap(name, in: view)
            action()
        }
    }
}

struct LoggableTextField: ViewModifier {
    let fieldName: String
    let view: String
    @Binding var text: String
    
    func body(content: Content) -> some View {
        content.onChange(of: text) { oldValue, newValue in
            UIEventLogger.shared.logTextInput(fieldName, oldValue: oldValue, newValue: newValue, in: view)
        }
    }
}

struct LoggableList: ViewModifier {
    let view: String
    
    func body(content: Content) -> some View {
        content
    }
}

// MARK: - View Extensions

extension View {
    func logButton(_ name: String, in view: String, action: @escaping () -> Void) -> some View {
        self.modifier(LoggableButton(name: name, view: view, action: action))
    }
    
    func logTextField(_ fieldName: String, in view: String, text: Binding<String>) -> some View {
        self.modifier(LoggableTextField(fieldName: fieldName, view: view, text: text))
    }
    
    func logViewAppear(_ view: String, module: String, captureState: @escaping () -> [String: Any] = { [:] }) -> some View {
        self.onAppear {
            NavigationTracker.shared.trackScreen(view, metadata: ["module": module])
            let state = captureState()
            if !state.isEmpty {
                UIEventLogger.shared.logViewState(view, state: state)
            }
        }
    }
}

// MARK: - Automated View State Capture

protocol LoggableView {
    var viewName: String { get }
    var moduleName: String { get }
    func captureState() -> [String: Any]
}

extension LoggableView where Self: View {
    func withAutoLogging() -> some View {
        self.logViewAppear(viewName, module: moduleName) {
            captureState()
        }
    }
} 