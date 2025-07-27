import SwiftUI
import Vision
import AVFoundation
import MessageUI

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @State private var showingPortfolioTracking = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("📊 Business Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    // Quick Stats with Haptics
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        StatCard(title: "Total Items", value: "\(inventoryManager.items.count)", color: .blue)
                            .onTapGesture {
                                hapticFeedback(.light)
                            }
                        StatCard(title: "To List", value: "\(inventoryManager.itemsToList)", color: .red)
                            .onTapGesture {
                                hapticFeedback(.light)
                            }
                        StatCard(title: "Listed", value: "\(inventoryManager.listedItems)", color: .orange)
                            .onTapGesture {
                                hapticFeedback(.light)
                            }
                        StatCard(title: "Sold", value: "\(inventoryManager.soldItems)", color: .green)
                            .onTapGesture {
                                hapticFeedback(.light)
                            }
                    }
                    
                    // Financial Overview
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💰 Financial Overview")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        FinancialCard(
                            title: "Total Investment",
                            amount: inventoryManager.totalInvestment,
                            color: .blue
                        )
                        
                        FinancialCard(
                            title: "Total Profit",
                            amount: inventoryManager.totalProfit,
                            color: .green
                        )
                        
                        FinancialCard(
                            title: "Average ROI",
                            amount: inventoryManager.averageROI,
                            color: .purple,
                            isPercentage: true
                        )
                        
                        // Portfolio Tracking Button
                        Button(action: {
                            hapticFeedback(.medium)
                            showingPortfolioTracking = true
                        }) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("📈 Portfolio Tracking")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🕒 Recent Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(inventoryManager.recentItems.prefix(5)) { item in
                            RecentItemCard(item: item)
                                .onTapGesture {
                                    hapticFeedback(.light)
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPortfolioTracking) {
            PortfolioTrackingView()
                .environmentObject(inventoryManager)
        }
    }
}

// MARK: - Portfolio Tracking View
struct PortfolioTrackingView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTimeframe = "All Time"
    
    let timeframes = ["7 Days", "30 Days", "90 Days", "All Time"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("📈 Portfolio Tracking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    // Timeframe Picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(timeframes, id: \.self) { timeframe in
                            Text(timeframe).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Portfolio Summary Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        PortfolioCard(
                            title: "Total Value",
                            value: String(format: "$%.2f", inventoryManager.totalEstimatedValue),
                            color: .blue,
                            icon: "dollarsign.circle.fill"
                        )
                        
                        PortfolioCard(
                            title: "Investment",
                            value: String(format: "$%.2f", inventoryManager.totalInvestment),
                            color: .orange,
                            icon: "creditcard.fill"
                        )
                        
                        PortfolioCard(
                            title: "Potential Profit",
                            value: String(format: "$%.2f", inventoryManager.totalEstimatedValue - inventoryManager.totalInvestment),
                            color: .green,
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        
                        PortfolioCard(
                            title: "Items",
                            value: "\(inventoryManager.items.count)",
                            color: .purple,
                            icon: "cube.box.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Category Breakdown
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📊 Category Breakdown")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        CategoryBreakdownView(items: inventoryManager.items)
                    }
                    
                    // Recent Performance
                    VStack(alignment: .leading, spacing: 15) {
                        Text("⚡ Performance Metrics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        PerformanceMetricsView(items: inventoryManager.items)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        hapticFeedback(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Portfolio Card
struct PortfolioCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 100)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Category Breakdown View
struct CategoryBreakdownView: View {
    let items: [InventoryItem]
    
    var categoryData: [CategoryData] {
        let grouped = Dictionary(grouping: items, by: { $0.category })
        return grouped.map { category, items in
            CategoryData(
                name: category,
                count: items.count,
                value: items.reduce(0) { $0 + $1.suggestedPrice },
                profit: items.reduce(0) { $0 + $1.estimatedProfit }
            )
        }.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(categoryData.prefix(5), id: \.name) { category in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("\(category.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "$%.0f", category.value))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text(String(format: "+$%.0f", category.profit))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Performance Metrics View
struct PerformanceMetricsView: View {
    let items: [InventoryItem]
    
    var body: some View {
        VStack(spacing: 12) {
            MetricRow(
                title: "Best ROI Category",
                value: bestROICategory,
                color: .green
            )
            
            MetricRow(
                title: "Avg. Time to Sell",
                value: "14 days", // Calculate this based on sold items
                color: .blue
            )
            
            MetricRow(
                title: "Success Rate",
                value: "\(Int(Double(soldItemsCount) / Double(max(items.count, 1)) * 100))%",
                color: .purple
            )
            
            MetricRow(
                title: "Total ROI",
                value: "\(Int(totalROI))%",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
    
    private var bestROICategory: String {
        let categoryROI = Dictionary(grouping: items, by: { $0.category })
            .mapValues { items in
                items.reduce(0) { $0 + $1.estimatedROI } / Double(items.count)
            }
        return categoryROI.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
    
    private var soldItemsCount: Int {
        items.filter { $0.status == .sold }.count
    }
    
    private var totalROI: Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0) { $0 + $1.estimatedROI } / Double(items.count)
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CategoryData {
    let name: String
    let count: Int
    let value: Double
    let profit: Double
}

// MARK: - Barcode Scanner View
struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ScannerDelegate {
        let parent: BarcodeScannerView
        
        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func didScanBarcode(_ code: String) {
            parent.scannedCode = code
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Scanner View Controller
protocol ScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
}

class ScannerViewController: UIViewController {
    weak var delegate: ScannerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }
    
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get camera")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add video input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce]
        } else {
            print("Could not add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add scanner overlay
        addScannerOverlay()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func addScannerOverlay() {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let scanRect = CGRect(x: 50, y: 200, width: view.bounds.width - 100, height: 200)
        let scanRectPath = UIBezierPath(rect: scanRect)
        let overlayPath = UIBezierPath(rect: overlayView.bounds)
        overlayPath.append(scanRectPath.reversing())
        
        let overlayLayer = CAShapeLayer()
        overlayLayer.path = overlayPath.cgPath
        overlayLayer.fillRule = .evenOdd
        overlayView.layer.addSublayer(overlayLayer)
        
        // Add instructions
        let instructionLabel = UILabel()
        instructionLabel.text = "📱 Scan barcode to instantly lookup product"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        instructionLabel.textAlignment = .center
        instructionLabel.frame = CGRect(x: 20, y: scanRect.maxY + 20, width: view.bounds.width - 40, height: 30)
        overlayView.addSubview(instructionLabel)
        
        view.addSubview(overlayView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }
}

// MARK: - Barcode Detection
extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Haptic feedback for successful scan
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            delegate?.didScanBarcode(stringValue)
        }
    }
}

// MARK: - Auto-Listing Generator
struct AutoListingView: View {
    let item: InventoryItem
    @State private var generatedListing = ""
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    @State private var showingEditSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("🚀 Auto-Generated eBay Listing")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    // Item Preview
                    ItemPreviewCard(item: item)
                    
                    // Generate Button
                    if generatedListing.isEmpty {
                        Button(action: {
                            hapticFeedback(.medium)
                            generateListing()
                        }) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Generating...")
                                } else {
                                    Image(systemName: "wand.and.stars")
                                    Text("🤖 Generate Complete eBay Listing")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                        .disabled(isGenerating)
                    } else {
                        // Generated Listing Display
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📝 Generated eBay Listing")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ScrollView {
                                Text(generatedListing)
                                    .font(.body)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .frame(maxHeight: 300)
                            
                            // Action Buttons
                            HStack(spacing: 15) {
                                Button(action: {
                                    hapticFeedback(.light)
                                    showingEditSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    hapticFeedback(.medium)
                                    showingShareSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share/Send")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                hapticFeedback(.light)
                                copyToClipboard()
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("📋 Copy to Clipboard")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        hapticFeedback(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generatedListing])
        }
        .sheet(isPresented: $showingEditSheet) {
            ListingEditView(listing: $generatedListing)
        }
    }
    
    private func generateListing() {
        isGenerating = true
        
        // Simulate AI generation with realistic listing content
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            generatedListing = generateEbayListing(for: item)
        }
    }
    
    private func generateEbayListing(for item: InventoryItem) -> String {
        return """
        🔥 \(item.title) 🔥
        
        ⭐ CONDITION: \(item.condition) - \(item.description)
        
        📦 FAST SHIPPING:
        • Same or next business day shipping
        • Carefully packaged with tracking
        • 30-day return policy
        
        💎 ITEM DETAILS:
        • Category: \(item.category)
        • Keywords: \(item.keywords.joined(separator: ", "))
        • Authentic & Verified
        
        🎯 WHY BUY FROM US:
        ✅ Top-rated seller
        ✅ 100% authentic items
        ✅ Fast & secure shipping
        ✅ Excellent customer service
        
        📱 QUESTIONS? Message us anytime!
        
        🔍 Search terms: \(item.keywords.joined(separator: " "))
        
        #\(item.keywords.joined(separator: " #"))
        
        Starting bid: $\(String(format: "%.2f", item.suggestedPrice * 0.7))
        Buy It Now: $\(String(format: "%.2f", item.suggestedPrice))
        
        Thank you for shopping with us! 🙏
        """
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatedListing
        // Show toast or alert that it was copied
    }
}

// MARK: - Item Preview Card
struct ItemPreviewCard: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(spacing: 12) {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Price:")
                    Spacer()
                    Text(String(format: "$%.2f", item.suggestedPrice))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Condition:")
                    Spacer()
                    Text(item.condition)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Listing Edit View
struct ListingEditView: View {
    @Binding var listing: String
    @Environment(\.presentationMode) var presentationMode
    @State private var editedListing: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("✏️ Edit Your Listing")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                TextEditor(text: $editedListing)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
                
                Button(action: {
                    hapticFeedback(.medium)
                    listing = editedListing
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("💾 Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        hapticFeedback(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            editedListing = listing
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Inventory View (Updated with new features)
struct InventoryView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    @State private var searchText = ""
    @State private var filterStatus: ItemStatus?
    @State private var showingFilters = false
    @State private var showingBarcodeScanner = false
    @State private var scannedBarcode: String?
    @State private var selectedItem: InventoryItem?
    @State private var showingAutoListing = false
    
    var filteredItems: [InventoryItem] {
        inventoryManager.items
            .filter { item in
                if let status = filterStatus {
                    return item.status == status
                }
                return true
            }
            .filter { item in
                if searchText.isEmpty {
                    return true
                }
                return item.name.localizedCaseInsensitiveContains(searchText) ||
                       item.source.localizedCaseInsensitiveContains(searchText)
            }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Enhanced Search Bar with Barcode Scanner
                HStack {
                    SearchBar(text: $searchText)
                    
                    Button(action: {
                        hapticFeedback(.light)
                        showingBarcodeScanner = true
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(.trailing, 8)
                    }
                }
                
                List {
                    ForEach(filteredItems) { item in
                        EnhancedInventoryItemRow(item: item) { updatedItem in
                            inventoryManager.updateItem(updatedItem)
                            googleSheetsService.updateItem(updatedItem)
                        } onAutoList: { item in
                            selectedItem = item
                            showingAutoListing = true
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("All Items") {
                            hapticFeedback(.light)
                            filterStatus = nil
                        }
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Button(status.rawValue) {
                                hapticFeedback(.light)
                                filterStatus = status
                            }
                        }
                        Divider()
                        Button("📊 Export to CSV") {
                            hapticFeedback(.medium)
                            exportToCSV()
                        }
                        Button("🔄 Sync to Google Sheets") {
                            hapticFeedback(.medium)
                            googleSheetsService.syncAllItems(inventoryManager.items)
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingBarcodeScanner) {
            BarcodeScannerView(scannedCode: $scannedBarcode)
                .onDisappear {
                    if let barcode = scannedBarcode {
                        // Handle barcode lookup
                        lookupProduct(barcode: barcode)
                    }
                }
        }
        .sheet(isPresented: $showingAutoListing) {
            if let item = selectedItem {
                AutoListingView(item: item)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        hapticFeedback(.medium)
        inventoryManager.deleteItems(at: offsets, from: filteredItems)
    }
    
    private func exportToCSV() {
        let csv = inventoryManager.exportCSV()
        // Handle CSV export - could save to files or share
        print("📄 CSV Export: \(csv.prefix(200))...")
    }
    
    private func lookupProduct(barcode: String) {
        hapticFeedback(.success)
        print("🔍 Looking up barcode: \(barcode)")
        // TODO: Implement UPC/ISBN lookup API
        // This would call a product database API to get item details
    }
}

// MARK: - Enhanced Inventory Item Row
struct EnhancedInventoryItemRow: View {
    let item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    let onAutoList: (InventoryItem) -> Void
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("\(item.source) • $\(String(format: "%.2f", item.purchasePrice))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if item.profit > 0 {
                    Text("Profit: $\(String(format: "%.2f", item.profit)) (\(String(format: "%.1f", item.roi))%)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(12)
                
                // Auto-List Button
                Button(action: {
                    hapticFeedback(.light)
                    onAutoList(item)
                }) {
                    Image(systemName: "wand.and.stars")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text("#\(item.itemNumber)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hapticFeedback(.light)
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            ItemDetailView(item: item, onUpdate: onUpdate)
        }
    }
}

// MARK: - Search Bar (Existing)
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search items...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

// MARK: - Recent Item Card (Existing)
struct RecentItemCard: View {
    let item: InventoryItem
    
    var body: some View {
        HStack {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(item.source)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(12)
                
                Text(String(format: "$%.2f", item.purchasePrice))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Item Detail View (Existing)
struct ItemDetailView: View {
    @State var item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCopyAlert = false
    @State private var copiedText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Photo") {
                    if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    }
                }
                
                Section("eBay Listing") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.title)
                        
                        Button("📋 Copy Title") {
                            hapticFeedback(.light)
                            UIPasteboard.general.string = item.title
                            copiedText = "Title copied!"
                            showingCopyAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.description)
                        
                        Button("📋 Copy Description") {
                            hapticFeedback(.light)
                            UIPasteboard.general.string = item.description
                            copiedText = "Description copied!"
                            showingCopyAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Keywords")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.keywords.joined(separator: ", "))
                        
                        Button("📋 Copy Keywords") {
                            hapticFeedback(.light)
                            UIPasteboard.general.string = item.keywords.joined(separator: ", ")
                            copiedText = "Keywords copied!"
                            showingCopyAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Section("Status & Pricing") {
                    Picker("Status", selection: $item.status) {
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    if item.status == .sold {
                        HStack {
                            Text("Sale Price")
                            TextField("0.00", value: $item.actualPrice, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                
                Section("Financial Details") {
                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        Text(String(format: "$%.2f", item.purchasePrice))
                    }
                    
                    HStack {
                        Text("Suggested Price")
                        Spacer()
                        Text(String(format: "$%.2f", item.suggestedPrice))
                    }
                    
                    if item.profit > 0 {
                        HStack {
                            Text("Profit")
                            Spacer()
                            Text(String(format: "$%.2f", item.profit))
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("ROI")
                            Spacer()
                            Text(String(format: "%.1f%%", item.roi))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Item #\(item.itemNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        hapticFeedback(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        hapticFeedback(.medium)
                        onUpdate(item)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert("Copied!", isPresented: $showingCopyAlert) {
            Button("OK") { }
        } message: {
            Text(copiedText)
        }
    }
}

// MARK: - Haptic Feedback Helper
func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let impactFeedback = UIImpactFeedbackGenerator(style: style)
    impactFeedback.impactOccurred()
}

extension UIImpactFeedbackGenerator.FeedbackStyle {
    static let success = UIImpactFeedbackGenerator.FeedbackStyle.heavy
}
