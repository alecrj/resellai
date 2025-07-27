import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - 🚀 FIXED MAIN CONTENT VIEW
struct ContentView: View {
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var revolutionaryAI = RevolutionaryAIService()
    @StateObject private var googleSheetsService = EnhancedGoogleSheetsService()
    @StateObject private var ebayListingService = DirectEbayListingService()
    
    // 🎯 HOMEPAGE MODE TOGGLE
    @State private var isProspectingMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔥 HOMEPAGE MODE TOGGLE
            HomepageModeToggle(isProspectingMode: $isProspectingMode)
            
            // Main Content
            if isProspectingMode {
                // 🔍 PROSPECTING MODE
                ProspectingModeView()
                    .environmentObject(inventoryManager)
                    .environmentObject(revolutionaryAI)
            } else {
                // 📦 BUSINESS MODE
                BusinessModeTabView()
                    .environmentObject(inventoryManager)
                    .environmentObject(revolutionaryAI)
                    .environmentObject(googleSheetsService)
                    .environmentObject(ebayListingService)
            }
        }
        .onAppear {
            googleSheetsService.authenticate()
        }
    }
}

// MARK: - 🎯 HOMEPAGE MODE TOGGLE
struct HomepageModeToggle: View {
    @Binding var isProspectingMode: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("ResellAI")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            // Mode Toggle
            HStack(spacing: 0) {
                // Business Mode Button
                Button(action: {
                    empireHaptic(.medium)
                    isProspectingMode = false
                }) {
                    HStack {
                        Image(systemName: "building.2.fill")
                        Text("Business Mode")
                    }
                    .font(.headline)
                    .foregroundColor(isProspectingMode ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isProspectingMode ? Color.gray.opacity(0.2) : Color.blue)
                    .animation(.easeInOut(duration: 0.2), value: isProspectingMode)
                }
                
                // Prospecting Mode Button
                Button(action: {
                    empireHaptic(.medium)
                    isProspectingMode = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Prospecting")
                    }
                    .font(.headline)
                    .foregroundColor(isProspectingMode ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isProspectingMode ? Color.purple : Color.gray.opacity(0.2))
                    .animation(.easeInOut(duration: 0.2), value: isProspectingMode)
                }
            }
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Mode Description
            Text(isProspectingMode ?
                 "🔍 Analyze items instantly • Get max buy price • Perfect for sourcing" :
                 "📦 Manage inventory • Track profits • Auto-generate eBay listings")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - 📦 BUSINESS MODE TAB VIEW
struct BusinessModeTabView: View {
    var body: some View {
        TabView {
            RevolutionaryAnalysisView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("🚀 Launchpad")
                }
            
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("📊 Dashboard")
                }
            
            InventoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("📦 Inventory")
                }
            
            RevolutionarySettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("⚙️ Settings")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - 🚀 FIXED Revolutionary Analysis View
struct RevolutionaryAnalysisView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var revolutionaryAI: RevolutionaryAIService
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    @EnvironmentObject var ebayListingService: DirectEbayListingService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingMultiCamera = false
    @State private var showingPhotoLibrary = false
    @State private var analysisResult: RevolutionaryAnalysis?
    @State private var showingItemForm = false
    @State private var showingDirectListing = false
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Revolutionary Header
                    VStack(spacing: 8) {
                        Text("🚀 AI ANALYSIS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Complete inventory analysis • eBay listing generation")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Analysis Progress - FIXED
                        if revolutionaryAI.isAnalyzing {
                            VStack(spacing: 8) {
                                ProgressView(value: Double(revolutionaryAI.currentStep), total: Double(revolutionaryAI.totalSteps))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                
                                Text(revolutionaryAI.analysisProgress)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Text("Step \(revolutionaryAI.currentStep)/\(revolutionaryAI.totalSteps)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // FIXED Multi-Photo Interface
                    if !capturedImages.isEmpty {
                        FixedPhotoGallery(images: $capturedImages)
                    } else {
                        FixedPhotoPlaceholder {
                            showingMultiCamera = true
                        }
                    }
                    
                    // FIXED Action Buttons with Barcode
                    FixedActionButtons(
                        hasPhotos: !capturedImages.isEmpty,
                        isAnalyzing: revolutionaryAI.isAnalyzing,
                        photoCount: capturedImages.count,
                        onTakePhotos: { showingMultiCamera = true },
                        onAddPhotos: { showingPhotoLibrary = true },
                        onBarcodeScan: { showingBarcodeLookup = true },
                        onAnalyze: { analyzeWithRevolutionaryAI() },
                        onReset: { resetAnalysis() }
                    )
                    
                    // Revolutionary Analysis Results
                    if let result = analysisResult {
                        RevolutionaryAnalysisResultView(analysis: result) {
                            showingItemForm = true
                        } onDirectList: {
                            showingDirectListing = true
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingMultiCamera) {
            FixedCameraView { photos in
                capturedImages.append(contentsOf: photos)
                analysisResult = nil
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            FixedPhotoLibraryPicker { photos in
                capturedImages.append(contentsOf: photos)
                analysisResult = nil
            }
        }
        .sheet(isPresented: $showingItemForm) {
            if let result = analysisResult {
                RevolutionaryItemFormView(
                    analysis: result,
                    onSave: { item in
                        inventoryManager.addItem(item)
                        googleSheetsService.uploadItem(item)
                        showingItemForm = false
                        resetAnalysis()
                    }
                )
                .environmentObject(inventoryManager)
            }
        }
        .sheet(isPresented: $showingDirectListing) {
            if let result = analysisResult {
                DirectEbayListingView(analysis: result)
                    .environmentObject(ebayListingService)
            }
        }
        .sheet(isPresented: $showingBarcodeLookup) {
            BarcodeScannerView(scannedCode: $scannedBarcode)
                .onDisappear {
                    if let barcode = scannedBarcode {
                        analyzeBarcode(barcode)
                    }
                }
        }
    }
    
    private func analyzeWithRevolutionaryAI() {
        guard !capturedImages.isEmpty else { return }
        
        empireHaptic(.medium)
        revolutionaryAI.revolutionaryAnalysis(capturedImages) { result in
            DispatchQueue.main.async {
                analysisResult = result
            }
        }
    }
    
    private func analyzeBarcode(_ barcode: String) {
        empireHaptic(.success)
        revolutionaryAI.analyzeBarcode(barcode, images: capturedImages) { result in
            DispatchQueue.main.async {
                analysisResult = result
            }
        }
    }
    
    private func resetAnalysis() {
        empireHaptic(.light)
        capturedImages = []
        analysisResult = nil
    }
}

// MARK: - 🔍 PROSPECTING MODE VIEW (CLEAN VERSION)
struct ProspectingModeView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var revolutionaryAI: RevolutionaryAIService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingMultiCamera = false
    @State private var showingPhotoLibrary = false
    @State private var prospectAnalysis: ProspectAnalysis?
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    @State private var selectedCategory = "All Categories"
    
    let categories = ["All Categories", "Electronics", "Gaming", "Clothing", "Collectibles", "Home & Garden", "Sports", "Books", "Toys"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 🔍 Prospecting Header
                    VStack(spacing: 12) {
                        Text("🔍 PROSPECTING MODE")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Text("Instant analysis • Max buy price • Perfect for sourcing")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Analysis Progress
                    if revolutionaryAI.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView(value: Double(revolutionaryAI.currentStep), total: Double(revolutionaryAI.totalSteps))
                                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                            
                            Text(revolutionaryAI.analysisProgress)
                                .font(.caption)
                                .foregroundColor(.purple)
                            
                            Text("Prospecting Analysis: Step \(revolutionaryAI.currentStep)/\(revolutionaryAI.totalSteps)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Photo Interface
                    if !capturedImages.isEmpty {
                        FixedPhotoGallery(images: $capturedImages)
                    } else {
                        ProspectingPhotoPlaceholder {
                            showingMultiCamera = true
                        }
                    }
                    
                    // Analysis Methods
                    VStack(spacing: 15) {
                        // Take Photos Button
                        Button(action: {
                            empireHaptic(.medium)
                            showingMultiCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                VStack(alignment: .leading) {
                                    Text("📸 Take Photos")
                                        .fontWeight(.bold)
                                    Text("Take up to 8 photos for analysis")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Add from Library Button
                        Button(action: {
                            empireHaptic(.medium)
                            showingPhotoLibrary = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                VStack(alignment: .leading) {
                                    Text("🖼️ Add from Library")
                                        .fontWeight(.bold)
                                    Text("Select photos from your library")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Barcode Lookup Button
                        Button(action: {
                            empireHaptic(.medium)
                            showingBarcodeLookup = true
                        }) {
                            HStack {
                                Image(systemName: "barcode.viewfinder")
                                VStack(alignment: .leading) {
                                    Text("📱 Barcode Scanner")
                                        .fontWeight(.bold)
                                    Text("Scan UPC/ISBN for instant lookup")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Analyze Photos Button
                        if !capturedImages.isEmpty {
                            Button(action: {
                                empireHaptic(.heavy)
                                analyzeForMaxBuyPrice()
                            }) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                    Text("🔍 GET MAX BUY PRICE (\(capturedImages.count) photos)")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.red, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                            .disabled(revolutionaryAI.isAnalyzing)
                        }
                    }
                    
                    // Analysis Results
                    if let analysis = prospectAnalysis {
                        ProspectAnalysisResultView(analysis: analysis)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingMultiCamera) {
            FixedCameraView { photos in
                capturedImages.append(contentsOf: photos)
                prospectAnalysis = nil
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            FixedPhotoLibraryPicker { photos in
                capturedImages.append(contentsOf: photos)
                prospectAnalysis = nil
            }
        }
        .sheet(isPresented: $showingBarcodeLookup) {
            BarcodeScannerView(scannedCode: $scannedBarcode)
                .onDisappear {
                    if let barcode = scannedBarcode {
                        lookupBarcode(barcode)
                    }
                }
        }
    }
    
    private func analyzeForMaxBuyPrice() {
        guard !capturedImages.isEmpty else { return }
        
        // 🎯 PROSPECTING MODE
        revolutionaryAI.analyzeForProspecting(
            images: capturedImages,
            category: selectedCategory
        ) { analysis in
            DispatchQueue.main.async {
                prospectAnalysis = analysis
            }
        }
    }
    
    private func lookupBarcode(_ barcode: String) {
        empireHaptic(.success)
        revolutionaryAI.lookupBarcodeForProspecting(barcode) { analysis in
            DispatchQueue.main.async {
                prospectAnalysis = analysis
            }
        }
    }
}

// MARK: - 🔧 FIXED UI COMPONENTS

// FIXED Photo Placeholder
struct FixedPhotoPlaceholder: View {
    let onTakePhotos: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 300)
            
            VStack(spacing: 20) {
                Image(systemName: "camera.fill") // FIXED: Valid SF Symbol
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Take Multiple Photos")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Take up to 8 photos for item analysis")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    Text("✓ Computer vision analysis")
                    Text("✓ Real-time market research")
                    Text("✓ Realistic pricing")
                    Text("✓ Direct eBay listing")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .onTapGesture {
            empireHaptic(.light)
            onTakePhotos()
        }
    }
}

// Prospecting Photo Placeholder
struct ProspectingPhotoPlaceholder: View {
    let onTakePhotos: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.1), .pink.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 300)
            
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                VStack(spacing: 8) {
                    Text("Prospecting Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Get instant max buy price for any item")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    Text("✓ Instant item identification")
                    Text("✓ Max buy price calculation")
                    Text("✓ Profit potential analysis")
                    Text("✓ Buy/Avoid recommendation")
                }
                .font(.caption)
                .foregroundColor(.purple)
            }
        }
        .onTapGesture {
            empireHaptic(.light)
            onTakePhotos()
        }
    }
}

// FIXED Photo Gallery
struct FixedPhotoGallery: View {
    @Binding var images: [UIImage]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Photo Display
            TabView(selection: $selectedIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 320)
            
            // Photo Controls
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📸 \(selectedIndex + 1) of \(images.count) photos")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Multi-angle analysis ready")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    empireHaptic(.light)
                    deleteCurrentPhoto()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func deleteCurrentPhoto() {
        if images.count > 1 {
            images.remove(at: selectedIndex)
            if selectedIndex >= images.count {
                selectedIndex = images.count - 1
            }
        } else {
            images.removeAll()
            selectedIndex = 0
        }
    }
}

// FIXED Action Buttons with Barcode Support
struct FixedActionButtons: View {
    let hasPhotos: Bool
    let isAnalyzing: Bool
    let photoCount: Int
    let onTakePhotos: () -> Void
    let onAddPhotos: () -> Void
    let onBarcodeScan: () -> Void
    let onAnalyze: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Photo and Barcode Row
            HStack(spacing: 10) {
                // Take Photos Button
                Button(action: {
                    empireHaptic(.medium)
                    onTakePhotos()
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("📷 Camera")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                
                // Add Photos Button
                Button(action: {
                    empireHaptic(.medium)
                    onAddPhotos()
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("🖼️ Library")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                
                // Barcode Scanner Button
                Button(action: {
                    empireHaptic(.medium)
                    onBarcodeScan()
                }) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("📱 Barcode")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
            }
            
            // Analysis Button
            if hasPhotos {
                Button(action: {
                    empireHaptic(.heavy)
                    onAnalyze()
                }) {
                    HStack {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("🚀 Analyzing...")
                        } else {
                            Image(systemName: "brain.head.profile")
                            Text("🚀 ITEM ANALYSIS (\(photoCount) photos)")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.headline)
                    .shadow(radius: 5)
                }
                .disabled(isAnalyzing)
                
                // Reset Button
                if !isAnalyzing {
                    Button(action: {
                        empireHaptic(.light)
                        onReset()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset Analysis")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// MARK: - 🔧 FIXED CAMERA AND PHOTO PICKERS

// FIXED Camera View
struct FixedCameraView: UIViewControllerRepresentable {
    let onPhotosSelected: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> FixedCameraViewController {
        let controller = FixedCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: FixedCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FixedCameraDelegate {
        let parent: FixedCameraView
        
        init(_ parent: FixedCameraView) {
            self.parent = parent
        }
        
        func didCapturePhotos(_ photos: [UIImage]) {
            parent.onPhotosSelected(photos)
        }
    }
}

protocol FixedCameraDelegate: AnyObject {
    func didCapturePhotos(_ photos: [UIImage])
}

class FixedCameraViewController: UIViewController {
    weak var delegate: FixedCameraDelegate?
    private var capturedPhotos: [UIImage] = []
    private let maxPhotos = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }
    
    private func setupInterface() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "📸 Take Photos (0/\(maxPhotos))"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Take multiple angles for best analysis"
        instructionLabel.font = .systemFont(ofSize: 16)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .systemGray
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setTitle("📷 Take Photo", for: .normal)
        cameraButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        cameraButton.backgroundColor = .systemBlue
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.layer.cornerRadius = 12
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("✅ Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        doneButton.backgroundColor = .systemGreen
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 12
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(finishCapture), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 200),
            cameraButton.heightAnchor.constraint(equalToConstant: 50),
            
            doneButton.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 200),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func takePhoto() {
        guard capturedPhotos.count < maxPhotos else {
            let alert = UIAlertController(title: "Max Photos Reached", message: "You can take up to \(maxPhotos) photos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func finishCapture() {
        if !capturedPhotos.isEmpty {
            delegate?.didCapturePhotos(capturedPhotos)
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "No Photos", message: "Please take at least one photo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func updateUI() {
        if let titleLabel = view.subviews.compactMap({ $0 as? UILabel }).first {
            titleLabel.text = "📸 Take Photos (\(capturedPhotos.count)/\(maxPhotos))"
        }
    }
}

extension FixedCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            capturedPhotos.append(image)
            updateUI()
        }
        picker.dismiss(animated: true)
    }
}

// FIXED Photo Library Picker
struct FixedPhotoLibraryPicker: UIViewControllerRepresentable {
    let onPhotosSelected: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 8
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: FixedPhotoLibraryPicker
        
        init(_ parent: FixedPhotoLibraryPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.parent.onPhotosSelected(images)
            }
        }
    }
}

// MARK: - 🔧 HAPTIC FEEDBACK (SINGLE DEFINITION)
func empireHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let impactFeedback = UIImpactFeedbackGenerator(style: style)
    impactFeedback.impactOccurred()
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
