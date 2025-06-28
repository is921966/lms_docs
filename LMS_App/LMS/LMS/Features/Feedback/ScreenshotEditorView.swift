import SwiftUI
import PencilKit

struct ScreenshotEditorView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedTool: DrawingTool = .pen
    @State private var selectedColor: Color = .red
    @State private var isDrawing = true
    @Environment(\.dismiss) var dismiss
    
    enum DrawingTool {
        case pen
        case marker
        case arrow
        case rectangle
        case text
        
        var icon: String {
            switch self {
            case .pen: return "pencil"
            case .marker: return "highlighter"
            case .arrow: return "arrow.up.left"
            case .rectangle: return "rectangle"
            case .text: return "textformat"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Screenshot background
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                // Canvas for drawing
                CanvasView(
                    canvasView: $canvasView,
                    toolPicker: $toolPicker,
                    selectedColor: selectedColor,
                    isDrawing: isDrawing
                )
                .allowsHitTesting(isDrawing)
                
                // Drawing tools
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        // Tools
                        ForEach([DrawingTool.pen, .marker, .arrow, .rectangle], id: \.self) { tool in
                            Button(action: { selectedTool = tool }) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 20))
                                    .frame(width: 50, height: 50)
                                    .background(selectedTool == tool ? Color.blue : Color.clear)
                                    .foregroundColor(selectedTool == tool ? .white : .blue)
                            }
                        }
                        
                        Divider()
                            .frame(height: 30)
                            .padding(.horizontal, 10)
                        
                        // Colors
                        ForEach([Color.red, .blue, .green, .orange, .yellow], id: \.self) { color in
                            Button(action: { 
                                selectedColor = color
                                updateCanvasColor()
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 3)
                                    )
                            }
                            .padding(.horizontal, 5)
                        }
                        
                        Spacer()
                        
                        // Clear button
                        Button(action: clearCanvas) {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemBackground))
                    .shadow(radius: 5)
                }
            }
            .navigationTitle("Редактировать скриншот")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveAnnotatedImage()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            setupCanvas()
        }
    }
    
    private func setupCanvas() {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: UIColor.red, width: 3)
        
        // Enable tool picker on devices that support it
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let _ = windowScene.windows.first {
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
    }
    
    private func updateCanvasColor() {
        let uiColor = UIColor(selectedColor)
        
        switch selectedTool {
        case .pen:
            canvasView.tool = PKInkingTool(.pen, color: uiColor, width: 3)
        case .marker:
            canvasView.tool = PKInkingTool(.marker, color: uiColor.withAlphaComponent(0.5), width: 15)
        default:
            canvasView.tool = PKInkingTool(.pen, color: uiColor, width: 3)
        }
    }
    
    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
    
    private func saveAnnotatedImage() {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let annotatedImage = renderer.image { context in
            // Draw original image
            image.draw(at: .zero)
            
            // Draw annotations
            let drawingImage = canvasView.drawing.image(
                from: canvasView.bounds,
                scale: UIScreen.main.scale
            )
            
            // Scale drawing to match image size
            let scale = image.size.width / canvasView.bounds.width
            let scaledSize = CGSize(
                width: drawingImage.size.width * scale,
                height: drawingImage.size.height * scale
            )
            
            drawingImage.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        
        onSave(annotatedImage)
        dismiss()
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    let selectedColor: Color
    let isDrawing: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isDrawing
    }
} 