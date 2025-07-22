import SwiftUI

// MARK: - Device Detection

struct iPadDeviceInfo {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }
    
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
}

// MARK: - Adaptive Layout Modifiers

struct AdaptiveLayout: ViewModifier {
    let iPhoneSpacing: CGFloat
    let iPadSpacing: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(iPadDeviceInfo.isIPad ? iPadSpacing : iPhoneSpacing)
    }
}

struct AdaptiveColumns: ViewModifier {
    let minWidth: CGFloat
    let maxColumns: Int
    
    func body(content: Content) -> some View {
        if iPadDeviceInfo.isIPad {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(minimum: minWidth)), count: maxColumns),
                spacing: 20
            ) {
                content
            }
        } else {
            content
        }
    }
}

struct AdaptiveNavigationStyle: ViewModifier {
    func body(content: Content) -> some View {
        if iPadDeviceInfo.isIPad {
            NavigationView {
                content
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        } else {
            NavigationView {
                content
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

// MARK: - View Extensions

extension View {
    func adaptiveLayout(iPhone: CGFloat = 16, iPad: CGFloat = 32) -> some View {
        modifier(AdaptiveLayout(iPhoneSpacing: iPhone, iPadSpacing: iPad))
    }
    
    func adaptiveColumns(minWidth: CGFloat = 300, maxColumns: Int = 3) -> some View {
        modifier(AdaptiveColumns(minWidth: minWidth, maxColumns: maxColumns))
    }
    
    func adaptiveNavigationStyle() -> some View {
        modifier(AdaptiveNavigationStyle())
    }
    
    func adaptiveFrame(
        iPhoneWidth: CGFloat? = nil,
        iPadWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil
    ) -> some View {
        frame(
            width: iPadDeviceInfo.isIPad ? (iPadWidth ?? maxWidth) : iPhoneWidth
        )
    }
}

// MARK: - Adaptive Container

struct AdaptiveContainer<Content: View>: View {
    let content: Content
    let maxWidth: CGFloat
    
    init(maxWidth: CGFloat = 1000, @ViewBuilder content: () -> Content) {
        self.maxWidth = maxWidth
        self.content = content()
    }
    
    var body: some View {
        if iPadDeviceInfo.isIPad {
            HStack {
                Spacer()
                content
                    .frame(maxWidth: maxWidth)
                Spacer()
            }
        } else {
            content
        }
    }
}

// MARK: - Split View for iPad

struct AdaptiveSplitView<Master: View, Detail: View>: View {
    let master: Master
    let detail: Detail
    let showDetail: Bool
    
    init(
        showDetail: Bool = false,
        @ViewBuilder master: () -> Master,
        @ViewBuilder detail: () -> Detail
    ) {
        self.showDetail = showDetail
        self.master = master()
        self.detail = detail()
    }
    
    var body: some View {
        if iPadDeviceInfo.isIPad {
            HStack(spacing: 0) {
                master
                    .frame(width: 350)
                    .background(Color(UIColor.systemGroupedBackground))
                
                Divider()
                
                detail
                    .frame(maxWidth: .infinity)
            }
        } else {
            if showDetail {
                detail
            } else {
                master
            }
        }
    }
} 