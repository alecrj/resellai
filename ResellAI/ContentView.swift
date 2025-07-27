import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Revolutionary Main Content View
struct ContentView: View {
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var revolutionaryAI = RevolutionaryAIService()
    @StateObject private var googleSheetsService = EnhancedGoogleSheetsService()
    @StateObject private var ebayListingService = DirectEbayListingService()
    
    var body: some View {
        TabView {
            RevolutionaryAnalysisView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("🚀 AI Pro")
                }
                .environmentObject(inventoryManager)
                .environmentObject(revolutionaryAI)
                .environmentObject(googleSheetsService)
                .environmentObject(ebayListingService)
            
            ProspectingModeView()
                .tabItem {
                    Image(systemName: "magnifyingglass.circle")
                    Text("🔍 Prospect")
                }
            
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("📊 Dashboard")
                }
                .environmentObject(inventoryManager)
            
            InventoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("📦 Inventory")
                }
                .environmentObject(inventoryManager)
                .environmentObject(googleSheetsService)
            
            RevolutionarySettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("⚙️ Settings")
                }
                .environmentObject(revolutionaryAI)
                .environmentObject(googleSheetsService)
                .environmentObject(ebayListingService)
        }
        .accentColor(.blue)
        .onAppear {
            googleSheetsService.authenticate()
        }
    }
}

// MARK: - 🚀 Revolutionary Analysis View
struct RevolutionaryAnalysisView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var revolutionaryAI: RevolutionaryAIService
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    @EnvironmentObject var ebayListingService: DirectEbayListingService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingMultiCamera = false
    @State private var analysisResult: RevolutionaryAnalysis?
    @State private var showingItemForm = false
    @State private var showingDirectListing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Revolutionary Header
                    VStack(spacing: 8) {
                        Text("🚀 REVOLUTIONARY AI")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Ultra-Accurate • Real Market Data • Direct eBay Listing")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Analysis Progress
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
                    
                    // Multi-Photo Interface
                    if !capturedImages.isEmpty {
                        RevolutionaryPhotoGallery(images: $capturedImages)
                    } else {
                        RevolutionaryPhotoPlaceholder {
                            showingMultiCamera = true
                        }
                    }
                    
                    // Revolutionary Action Buttons
                    RevolutionaryActionButtons(
                        hasPhotos: !capturedImages.isEmpty,
                        isAnalyzing: revolutionaryAI.isAnalyzing,
                        photoCount: capturedImages.count,
                        onMultiCamera: { showingMultiCamera = true },
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
            MultiCameraViewRepresentable { photos in
                capturedImages = photos
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
    }
    
    private func analyzeWithRevolutionaryAI() {
        guard !capturedImages.isEmpty else { return }
        
        hapticFeedback(.medium)
        revolutionaryAI.revolutionaryAnalysis(capturedImages) { result in
            analysisResult = result
        }
    }
    
    private func resetAnalysis() {
        hapticFeedback(.light)
        capturedImages = []
        analysisResult = nil
    }
}

// MARK: - Revolutionary Photo Placeholder
struct RevolutionaryPhotoPlaceholder: View {
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
                Image(systemName: "camera.stack.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Revolutionary Multi-Photo Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Take multiple photos for ultra-accurate identification and realistic pricing")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    Text("✓ Computer vision damage detection")
                    Text("✓ Real-time market research")
                    Text("✓ Ultra-realistic pricing")
                    Text("✓ Direct eBay listing")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .onTapGesture {
            hapticFeedback(.light)
            onTakePhotos()
        }
    }
}

// MARK: - Revolutionary Photo Gallery
struct RevolutionaryPhotoGallery: View {
    @Binding var images: [UIImage]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Photo Display with enhanced UI
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
            
            // Enhanced Photo Controls
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📸 \(selectedIndex + 1) of \(images.count) photos")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Revolutionary multi-angle analysis")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    hapticFeedback(.light)
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

// MARK: - Revolutionary Action Buttons
struct RevolutionaryActionButtons: View {
    let hasPhotos: Bool
    let isAnalyzing: Bool
    let photoCount: Int
    let onMultiCamera: () -> Void
    let onAnalyze: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Multi-Camera Button
            Button(action: {
                hapticFeedback(.medium)
                onMultiCamera()
            }) {
                HStack {
                    Image(systemName: "camera.stack.fill")
                    Text(hasPhotos ? "📷 Add More Photos" : "📸 Take Multi-Angle Photos")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .font(.headline)
            }
            
            // Revolutionary Analysis Button
            if hasPhotos {
                Button(action: {
                    hapticFeedback(.heavy)
                    onAnalyze()
                }) {
                    HStack {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("🚀 Revolutionary Analysis...")
                        } else {
                            Image(systemName: "brain.head.profile")
                            Text("🚀 REVOLUTIONARY ANALYSIS (\(photoCount) photos)")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .mint, .blue],
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
                        hapticFeedback(.light)
                        onReset()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset Photos")
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

// MARK: - 🚀 Revolutionary Analysis Result View
struct RevolutionaryAnalysisResultView: View {
    let analysis: RevolutionaryAnalysis
    let onAddToInventory: () -> Void
    let onDirectList: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Revolutionary Header
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text("🚀 REVOLUTIONARY ANALYSIS")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Ultra-accurate • Real market data")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(analysis.confidence * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(analysis.confidence > 0.9 ? .green : .orange)
                    Text("Confidence")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Core Identification
            RevolutionaryIdentificationCard(analysis: analysis)
            
            // Condition Analysis
            RevolutionaryConditionCard(analysis: analysis)
            
            // Market Intelligence
            RevolutionaryMarketCard(analysis: analysis)
            
            // Profit Analysis
            RevolutionaryProfitCard(analysis: analysis)
            
            // Action Buttons
            RevolutionaryActionCards(
                onAddToInventory: onAddToInventory,
                onDirectList: onDirectList
            )
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.gray.opacity(0.05), Color.blue.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - Revolutionary Cards
struct RevolutionaryIdentificationCard: View {
    let analysis: RevolutionaryAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎯 IDENTIFICATION")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Item:")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(analysis.itemName)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                }
                
                if !analysis.modelNumber.isEmpty {
                    HStack {
                        Text("Model:")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(analysis.modelNumber)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                
                HStack {
                    Text("Brand:")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(analysis.brand)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}

struct RevolutionaryConditionCard: View {
    let analysis: RevolutionaryAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔍 CONDITION ANALYSIS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            
            VStack(spacing: 8) {
                HStack {
                    Text("AI Detected:")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(analysis.actualCondition)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(getConditionColor(analysis.actualCondition).opacity(0.2))
                        .foregroundColor(getConditionColor(analysis.actualCondition))
                        .cornerRadius(8)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Score:")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(analysis.conditionScore))/100")
                        .fontWeight(.bold)
                        .foregroundColor(analysis.conditionScore > 80 ? .green : analysis.conditionScore > 60 ? .orange : .red)
                }
                
                if !analysis.conditionReasons.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        ForEach(analysis.conditionReasons.prefix(3), id: \.self) { reason in
                            Text("• \(reason)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func getConditionColor(_ condition: String) -> Color {
        switch condition {
        case "Like New": return .green
        case "Excellent": return .blue
        case "Very Good": return .mint
        case "Good": return .orange
        case "Fair": return .red
        case "Poor": return .red
        default: return .gray
        }
    }
}

struct RevolutionaryMarketCard: View {
    let analysis: RevolutionaryAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 MARKET INTELLIGENCE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Realistic Price:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("$\(String(format: "%.2f", analysis.realisticPrice))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Market Range:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.0f", analysis.marketRange.low)) - $\(String(format: "%.0f", analysis.marketRange.high))")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Competition:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(analysis.competitorCount) active listings")
                        .font(.caption)
                        .foregroundColor(analysis.competitorCount > 1000 ? .red : analysis.competitorCount > 500 ? .orange : .green)
                }
                
                HStack {
                    Text("Demand:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(analysis.demandLevel)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(analysis.demandLevel == "High" ? .green : analysis.demandLevel == "Medium" ? .orange : .red)
                }
                
                if !analysis.marketTrend.isEmpty {
                    Text("📈 \(analysis.marketTrend)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }
}

struct RevolutionaryProfitCard: View {
    let analysis: RevolutionaryAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💰 PROFIT OPTIMIZATION")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Quick Sale:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", analysis.quickSalePrice))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Text("Max Profit:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", analysis.maxProfitPrice))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Total Fees:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", analysis.feesBreakdown.totalFees))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                if !analysis.listingStrategy.isEmpty {
                    Text("💡 \(analysis.listingStrategy)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
}

struct RevolutionaryActionCards: View {
    let onAddToInventory: () -> Void
    let onDirectList: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Add to Inventory Button
            Button(action: {
                hapticFeedback(.medium)
                onAddToInventory()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("📦 Add to Inventory")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)
            }
            
            // Direct eBay Listing Button
            Button(action: {
                hapticFeedback(.heavy)
                onDirectList()
            }) {
                HStack {
                    Image(systemName: "bolt.fill")
                    Text("🚀 List Directly to eBay")
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
                .font(.headline)
                .shadow(radius: 5)
            }
        }
    }
}

// MARK: - Direct eBay Listing View
struct DirectEbayListingView: View {
    let analysis: RevolutionaryAnalysis
    @EnvironmentObject var ebayListingService: DirectEbayListingService
    @Environment(\.presentationMode) var presentationMode
    @State private var listingPrice = ""
    @State private var customTitle = ""
    @State private var customDescription = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🚀 Direct eBay Listing")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    // Item Preview
                    if let firstImage = analysis.images.first {
                        Image(uiImage: firstImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                    }
                    
                    // Listing Form
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📝 Listing Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("eBay Title", text: $customTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onAppear {
                                    customTitle = analysis.ebayTitle
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Price")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Price", text: $listingPrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .onAppear {
                                    listingPrice = String(format: "%.2f", analysis.realisticPrice)
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $customDescription)
                                .frame(minHeight: 100)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .onAppear {
                                    customDescription = analysis.description
                                }
                        }
                    }
                    
                    // Listing Progress
                    if ebayListingService.isListing {
                        VStack(spacing: 10) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text(ebayListingService.listingProgress)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // List Button
                    if !ebayListingService.isListing {
                        Button(action: {
                            hapticFeedback(.heavy)
                            listToEbay()
                        }) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("🚀 LIST TO EBAY NOW")
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
                            .font(.headline)
                            .shadow(radius: 5)
                        }
                    }
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
        .alert("🎉 Listed Successfully!", isPresented: $showingSuccess) {
            Button("View Listing") {
                if let url = ebayListingService.listingURL,
                   let listingURL = URL(string: url) {
                    UIApplication.shared.open(listingURL)
                }
            }
            Button("OK") { }
        } message: {
            Text("Your item has been listed on eBay!")
        }
    }
    
    private func listToEbay() {
        // Create a temporary inventory item for listing
        let tempItem = InventoryItem(
            itemNumber: 0,
            name: analysis.itemName,
            category: analysis.category,
            purchasePrice: 0,
            suggestedPrice: Double(listingPrice) ?? analysis.realisticPrice,
            source: "Direct Listing",
            condition: analysis.actualCondition,
            title: customTitle,
            description: customDescription,
            keywords: analysis.keywords,
            status: .toList,
            dateAdded: Date()
        )
        
        ebayListingService.listDirectlyToEbay(item: tempItem, analysis: analysis) { success, url in
            if success {
                showingSuccess = true
            }
        }
    }
}

// MARK: - Revolutionary Item Form View
struct RevolutionaryItemFormView: View {
    let analysis: RevolutionaryAnalysis
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
        let selling = Double(adjustedPrice) ?? analysis.realisticPrice
        return selling - purchase - analysis.feesBreakdown.totalFees
    }
    
    var estimatedROI: Double {
        guard let purchase = Double(purchasePrice), purchase > 0 else { return 0 }
        return (estimatedProfit / purchase) * 100
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("🚀 Revolutionary Analysis") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if let firstImage = analysis.images.first {
                                Image(uiImage: firstImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(analysis.itemName)
                                    .fontWeight(.bold)
                                
                                Text("AI Condition: \(analysis.actualCondition)")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                
                                if !analysis.modelNumber.isEmpty {
                                    Text("Model: \(analysis.modelNumber)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                Text("\(analysis.images.count) photos • \(Int(analysis.confidence * 100))% confidence")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            Spacer()
                        }
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
                    
                    Picker("Condition Override", selection: $condition) {
                        Text("Use AI: \(analysis.actualCondition)").tag(analysis.actualCondition)
                        Text("New").tag("New")
                        Text("Like New").tag("Like New")
                        Text("Excellent").tag("Excellent")
                        Text("Very Good").tag("Very Good")
                        Text("Good").tag("Good")
                        Text("Fair").tag("Fair")
                        Text("Poor").tag("Poor")
                    }
                    .onAppear {
                        condition = analysis.actualCondition
                    }
                }
                
                Section("🎯 Revolutionary Pricing") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("AI Realistic Price:")
                            Spacer()
                            Text("$\(String(format: "%.2f", analysis.realisticPrice))")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Quick Sale:")
                            Spacer()
                            Text("$\(String(format: "%.2f", analysis.quickSalePrice))")
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("Max Profit:")
                            Spacer()
                            Text("$\(String(format: "%.2f", analysis.maxProfitPrice))")
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Market Range:")
                            Spacer()
                            Text("$\(String(format: "%.0f", analysis.marketRange.low)) - $\(String(format: "%.0f", analysis.marketRange.high))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Your Price ($)")
                        TextField("Price", text: $adjustedPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onAppear {
                                adjustedPrice = String(format: "%.2f", analysis.realisticPrice)
                            }
                    }
                    
                    if !purchasePrice.isEmpty {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Net Profit:")
                                Spacer()
                                Text("$\(String(format: "%.2f", estimatedProfit))")
                                    .fontWeight(.bold)
                                    .foregroundColor(estimatedProfit > 0 ? .green : .red)
                            }
                            
                            HStack {
                                Text("ROI:")
                                Spacer()
                                Text("\(String(format: "%.1f", estimatedROI))%")
                                    .fontWeight(.bold)
                                    .foregroundColor(estimatedROI > 200 ? .green : estimatedROI > 100 ? .orange : .red)
                            }
                            
                            HStack {
                                Text("All-in Fees:")
                                Spacer()
                                Text("$\(String(format: "%.2f", analysis.feesBreakdown.totalFees))")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Section("📝 Optimized Listing") {
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
                
                Section("🎯 Revolutionary Intelligence") {
                    VStack(alignment: .leading, spacing: 8) {
                        if !analysis.listingStrategy.isEmpty {
                            Text("Strategy: \(analysis.listingStrategy)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        if !analysis.sourcingTips.isEmpty {
                            Text("Sourcing Tips:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            ForEach(analysis.sourcingTips.prefix(2), id: \.self) { tip in
                                Text("• \(tip)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Revolutionary Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        hapticFeedback(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        hapticFeedback(.medium)
                        saveRevolutionaryItem()
                    }
                    .disabled(purchasePrice.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveRevolutionaryItem() {
        guard let price = Double(purchasePrice) else { return }
        let finalPrice = Double(adjustedPrice) ?? analysis.realisticPrice
        
        // Convert all images to data
        var imageDataArray: [Data] = []
        for image in analysis.images {
            if let data = image.jpegData(compressionQuality: 0.8) {
                imageDataArray.append(data)
            }
        }
        
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
            imageData: imageDataArray.first,
            additionalImageData: imageDataArray.count > 1 ? Array(imageDataArray.dropFirst()) : nil,
            resalePotential: analysis.resalePotential,
            marketNotes: analysis.marketTrend
        )
        
        onSave(item)
    }
}

// MARK: - Revolutionary Settings View
struct RevolutionarySettingsView: View {
    @EnvironmentObject var revolutionaryAI: RevolutionaryAIService
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    @EnvironmentObject var ebayListingService: DirectEbayListingService
    
    var body: some View {
        NavigationView {
            Form {
                Section("🚀 Revolutionary AI") {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Revolutionary Analysis Engine")
                                .fontWeight(.semibold)
                            Text("Ultra-accurate • Real market data • Computer vision")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Section("🚀 Direct eBay Listing") {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("One-Tap eBay Listing")
                                .fontWeight(.semibold)
                            Text(ebayListingService.isListing ? "Listing in progress..." : "Ready to list")
                                .font(.caption)
                                .foregroundColor(ebayListingService.isListing ? .orange : .green)
                        }
                        Spacer()
                        if ebayListingService.isListing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                Section("📊 Google Sheets") {
                    HStack {
                        Image(systemName: "tablecells")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Auto-Sync Inventory")
                                .fontWeight(.semibold)
                            Text(googleSheetsService.syncStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if googleSheetsService.isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                Section("🔥 Revolutionary Features") {
                    FeatureStatusRow(icon: "camera.stack.fill", title: "Multi-Photo Analysis", enabled: true)
                    FeatureStatusRow(icon: "eye.fill", title: "Computer Vision Condition Detection", enabled: true)
                    FeatureStatusRow(icon: "chart.line.uptrend.xyaxis", title: "Real-Time Market Research", enabled: true)
                    FeatureStatusRow(icon: "brain", title: "Ultra-Realistic AI Pricing", enabled: true)
                    FeatureStatusRow(icon: "bolt.fill", title: "Direct eBay Listing", enabled: true)
                    FeatureStatusRow(icon: "magnifyingglass.circle", title: "Prospecting Mode", enabled: true)
                    FeatureStatusRow(icon: "barcode.viewfinder", title: "Barcode Scanner", enabled: true)
                    FeatureStatusRow(icon: "wand.and.stars", title: "Auto-Listing Generator", enabled: true)
                }
            }
            .navigationTitle("Revolutionary Settings")
        }
    }
}

struct FeatureStatusRow: View {
    let icon: String
    let title: String
    let enabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
            Spacer()
            Image(systemName: enabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(enabled ? .green : .red)
        }
    }
}

// MARK: - Haptic Feedback Helper
func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let impactFeedback = UIImpactFeedbackGenerator(style: style)
    impactFeedback.impactOccurred()
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
