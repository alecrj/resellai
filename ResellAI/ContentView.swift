import SwiftUI
import UIKit
import AVFoundation

// MARK: - Models (keeping existing models)
struct InventoryItem: Identifiable, Codable {
    let id = UUID()
    var itemNumber: Int
    var name: String
    var category: String
    var purchasePrice: Double
    var suggestedPrice: Double
    var actualPrice: Double?
    var source: String
    var condition: String
    var title: String
    var description: String
    var keywords: [String]
    var status: ItemStatus
    var dateAdded: Date
    var dateListed: Date?
    var dateSold: Date?
    var imageData: Data?
    var ebayURL: String?
    var resalePotential: Int?
    var marketNotes: String?
    
    var profit: Double {
        guard let actualPrice = actualPrice else { return 0 }
        let fees = actualPrice * 0.13 // eBay + PayPal fees
        return actualPrice - purchasePrice - fees
    }
    
    var roi: Double {
        guard purchasePrice > 0 else { return 0 }
        return (profit / purchasePrice) * 100
    }
    
    var estimatedProfit: Double {
        let fees = suggestedPrice * 0.13
        return suggestedPrice - purchasePrice - fees
    }
    
    var estimatedROI: Double {
        guard purchasePrice > 0 else { return 0 }
        return (estimatedProfit / purchasePrice) * 100
    }
}

enum ItemStatus: String, CaseIterable, Codable {
    case photographed = "Photographed"
    case analyzed = "Analyzed"
    case toList = "To List"
    case listed = "Listed"
    case sold = "Sold"
    
    var color: Color {
        switch self {
        case .photographed: return .orange
        case .analyzed: return .blue
        case .toList: return .red
        case .listed: return .yellow
        case .sold: return .green
        }
    }
}

enum SourceLocation: String, CaseIterable {
    case cityWalk = "City Walk"
    case goodwillBins = "Goodwill Bins"
    case goodCents = "Good Cents"
    case estateSale = "Estate Sale"
    case yardSale = "Yard Sale"
    case online = "Online"
    case other = "Other"
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var aiService = AIService()
    @StateObject private var googleSheetsService = GoogleSheetsService()
    
    var body: some View {
        TabView {
            EnhancedCameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("AI Scan")
                }
                .environmentObject(inventoryManager)
                .environmentObject(aiService)
                .environmentObject(googleSheetsService)
            
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .environmentObject(inventoryManager)
            
            InventoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Inventory")
                }
                .environmentObject(inventoryManager)
                .environmentObject(googleSheetsService)
            
            EnhancedSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .environmentObject(aiService)
                .environmentObject(googleSheetsService)
        }
        .accentColor(.blue)
        .onAppear {
            // Initialize Google Sheets connection
            googleSheetsService.authenticate()
        }
    }
}

// MARK: - Enhanced Camera View with Real AI
struct EnhancedCameraView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var analysisResult: ItemAnalysis?
    @State private var showingItemForm = false
    @State private var analysisError: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🤖 AI ResellBot")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Snap • Analyze • Profit")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Image Display Area
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 300)
                            .overlay(
                                Group {
                                    if let image = capturedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(12)
                                    } else {
                                        VStack(spacing: 15) {
                                            Image(systemName: "camera.viewfinder")
                                                .font(.system(size: 60))
                                                .foregroundColor(.blue.opacity(0.6))
                                            Text("Tap to Capture Item")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            Text("AI will identify and price your item")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            )
                    }
                    .onTapGesture {
                        showingCamera = true
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Capture New Photo")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                        
                        if let image = capturedImage {
                            Button(action: {
                                analyzeWithAI(image)
                            }) {
                                HStack {
                                    if aiService.isAnalyzing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("AI Analyzing...")
                                    } else {
                                        Image(systemName: "brain.head.profile")
                                        Text("🤖 AI Analyze & Price")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.headline)
                            }
                            .disabled(aiService.isAnalyzing)
                        }
                    }
                    
                    // Error Display
                    if let error = analysisError {
                        Text("⚠️ \(error)")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Analysis Results
                    if let result = analysisResult {
                        EnhancedAnalysisResultView(analysis: result) {
                            showingItemForm = true
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCamera) {
            CameraViewRepresentable { image in
                capturedImage = image
                analysisResult = nil
                analysisError = nil
            }
        }
        .sheet(isPresented: $showingItemForm) {
            if let result = analysisResult, let image = capturedImage {
                EnhancedItemFormView(
                    analysis: result,
                    image: image,
                    onSave: { item in
                        inventoryManager.addItem(item)
                        googleSheetsService.uploadItem(item)
                        showingItemForm = false
                        capturedImage = nil
                        analysisResult = nil
                    }
                )
                .environmentObject(inventoryManager)
            }
        }
    }
    
    private func analyzeWithAI(_ image: UIImage) {
        analysisError = nil
        aiService.analyzeImage(image) { result in
            DispatchQueue.main.async {
                analysisResult = result
            }
        }
    }
}

// MARK: - Enhanced Analysis Result View
struct EnhancedAnalysisResultView: View {
    let analysis: ItemAnalysis
    let onProceed: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Header
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("AI Analysis Complete")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(Int(analysis.confidence * 100))%")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(analysis.confidence > 0.8 ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .foregroundColor(analysis.confidence > 0.8 ? .green : .orange)
                    .cornerRadius(12)
            }
            
            Divider()
            
            // Main Info
            VStack(spacing: 10) {
                HStack {
                    Text("Item:")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(analysis.itemName)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Condition:")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(analysis.condition)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                        .font(.caption)
                }
                
                HStack {
                    Text("Suggested Price:")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(analysis.suggestedPrice, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                if analysis.resalePotential > 0 {
                    HStack {
                        Text("Resale Score:")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(1...10, id: \.self) { index in
                                Image(systemName: index <= analysis.resalePotential ? "star.fill" : "star")
                                    .foregroundColor(index <= analysis.resalePotential ? .yellow : .gray.opacity(0.3))
                                    .font(.caption)
                            }
                        }
                        Text("\(analysis.resalePotential)/10")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Market Notes
            if !analysis.marketNotes.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("💡 Market Insights")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text(analysis.marketNotes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
            
            // Action Button
            Button(action: onProceed) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add to Inventory")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Enhanced Item Form View
struct EnhancedItemFormView: View {
    let analysis: ItemAnalysis
    let image: UIImage
    let onSave: (InventoryItem) -> Void
    
    @State private var purchasePrice = ""
    @State private var selectedSource = SourceLocation.cityWalk
    @State private var condition = "Good"
    @State private var customTitle = ""
    @State private var customDescription = ""
    @State private var adjustedPrice = ""
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var estimatedProfit: Double {
        guard let purchase = Double(purchasePrice) else { return 0 }
        let selling = Double(adjustedPrice) ?? analysis.suggestedPrice
        let fees = selling * 0.13
        return selling - purchase - fees
    }
    
    var estimatedROI: Double {
        guard let purchase = Double(purchasePrice), purchase > 0 else { return 0 }
        return (estimatedProfit / purchase) * 100
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("📸 Item Photo & AI Analysis") {
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(analysis.itemName)
                                .fontWeight(.bold)
                            Text(analysis.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text("AI Confidence:")
                                Text("\(Int(analysis.confidence * 100))%")
                                    .foregroundColor(analysis.confidence > 0.8 ? .green : .orange)
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                        }
                        Spacer()
                    }
                }
                
                Section("💰 Purchase Details") {
                    HStack {
                        Text("Purchase Price ($)")
                        TextField("0.00", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Source", selection: $selectedSource) {
                        ForEach(SourceLocation.allCases, id: \.self) { source in
                            Text(source.rawValue).tag(source)
                        }
                    }
                    
                    Picker("Condition", selection: $condition) {
                        Text("New").tag("New")
                        Text("Like New").tag("Like New")
                        Text("Good").tag("Good")
                        Text("Fair").tag("Fair")
                        Text("For Parts").tag("For Parts")
                    }
                }
                
                Section("🎯 Pricing & Profit") {
                    HStack {
                        Text("AI Suggested Price")
                        Spacer()
                        Text("$\(analysis.suggestedPrice, specifier: "%.2f")")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Your Price ($)")
                        TextField("\(analysis.suggestedPrice, specifier: "%.2f")", text: $adjustedPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if !purchasePrice.isEmpty {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Estimated Profit:")
                                Spacer()
                                Text("$\(estimatedProfit, specifier: "%.2f")")
                                    .foregroundColor(estimatedProfit > 0 ? .green : .red)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("ROI:")
                                Spacer()
                                Text("\(estimatedROI, specifier: "%.1f")%")
                                    .foregroundColor(estimatedROI > 200 ? .green : estimatedROI > 100 ? .orange : .red)
                                    .fontWeight(.bold)
                            }
                            
                            // ROI Warning
                            if estimatedROI < 200 {
                                Text("⚠️ ROI below 200% target")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Section("📝 eBay Listing Content") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title (\(customTitle.count)/80)")
                            .font(.caption)
                            .foregroundColor(customTitle.count > 80 ? .red : .secondary)
                        TextField("eBay Title", text: $customTitle)
                            .onAppear {
                                customTitle = analysis.ebayTitle
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $customDescription)
                            .frame(minHeight: 100)
                            .onAppear {
                                customDescription = analysis.description
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Keywords")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(analysis.keywords.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
            .navigationTitle("Add to Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save & Sync") {
                        saveItem()
                    }
                    .disabled(purchasePrice.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveItem() {
        guard let price = Double(purchasePrice) else { return }
        let finalPrice = Double(adjustedPrice) ?? analysis.suggestedPrice
        
        let item = InventoryItem(
            itemNumber: inventoryManager.nextItemNumber,
            name: analysis.itemName,
            category: analysis.category,
            purchasePrice: price,
            suggestedPrice: finalPrice,
            source: selectedSource.rawValue,
            condition: condition,
            title: customTitle,
            description: customDescription,
            keywords: analysis.keywords,
            status: .analyzed,
            dateAdded: Date(),
            imageData: image.jpegData(compressionQuality: 0.8),
            resalePotential: analysis.resalePotential,
            marketNotes: analysis.marketNotes
        )
        
        onSave(item)
    }
}

// MARK: - Keep existing camera representative and other supporting views
struct CameraViewRepresentable: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void
        
        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Keep existing supporting views and services
// (InventoryManager, StatCard, FinancialCard, etc. remain the same)

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
