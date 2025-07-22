import SwiftUI

struct RefreshView: View {
    var progress: Double = 0.0
    @State var animationPhase: Double = 0.0
    @State var isAnimating: Bool = false
    
    let primaryColor = Color.blue
    let secondaryColor = Color.blue.opacity(0.3)
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(secondaryColor, lineWidth: 3)
                .frame(width: 40, height: 40)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: isAnimating ? animationPhase : progress)
                .stroke(
                    primaryColor,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(isAnimating ? animationPhase * 360 : -90))
                .animation(
                    isAnimating ? 
                    Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false) :
                    .default,
                    value: animationPhase
                )
            
            // Center icon
            if !isAnimating && progress < 1.0 {
                Image(systemName: "arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryColor)
                    .scaleEffect(progress)
                    .opacity(progress)
            } else if isAnimating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                    .scaleEffect(0.8)
            }
        }
        .frame(width: 50, height: 50)
        .padding()
        .onChange(of: isAnimating) { oldValue, newValue in
            if newValue {
                withAnimation {
                    animationPhase = 1.0
                }
            } else {
                animationPhase = 0.0
            }
        }
    }
    
    mutating func startAnimation() {
        isAnimating = true
    }
    
    mutating func stopAnimation() {
        isAnimating = false
        animationPhase = 0.0
    }
}

struct RefreshView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            RefreshView(progress: 0.3)
            RefreshView(progress: 0.7)
            RefreshView(progress: 1.0)
        }
    }
} 