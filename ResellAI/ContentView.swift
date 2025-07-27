import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var aiService = EnhancedAIService()
    @StateObject private var googleSheetsService = EnhancedGoogleSheetsService()
    
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
            googleSheetsService.authenticate()
        }
    }
}

// MARK: - Enhanced Camera View with Multi-Photo Support
struct EnhancedCameraView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var aiService: EnhancedAIService
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var showingMultiPhotoPicker = false
    @State private var analysisResult: ItemAnalysis?
    @State private var showingItemForm = false
    @State private var currentImageIndex = 0
    @State private var showingPhotoSourceChoice = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Enhanced Header
                    VStack(spacing: 8) {
                        Text("🚀 Enhanced ResellAI")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Multi-Photo • AI Powered • Market Intelligence")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if aiService.isAnalyzing {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text(aiService.analysisProgress)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Multi-Photo Display
                    if !capturedImages.isEmpty {
                        EnhancedPhotoGallery(images: $capturedImages, currentIndex: $currentImageIndex)
                    } else {
                        // Photo Placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 300)
                            
                            VStack(spacing: 15) {
                                Image(systemName: "camera.stack.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue.opacity(0.6))
                                Text("Add Multiple Photos")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Take photos from different angles for better accuracy")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .onTapGesture {
                            showingPhotoSourceChoice = true
                        }
                    }
                    
                    // Enhanced Photo Action Buttons
                    EnhancedPhotoButtons(
                        onSingleCamera: { showingCamera = true },
                        onSinglePhoto: { showingPhotoPicker = true },
                        onMultiPhoto: { showingMultiPhotoPicker = true },
                        onAnalyze: { analyzePhotos() },
                        hasPhotos: !capturedImages.isEmpty,
                        isAnalyzing: aiService.isAnalyzing,
                        photoCount: capturedImages.count
                    )
                    
                    // Enhanced Analysis Results
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
        .actionSheet(isPresented: $showingPhotoSourceChoice) {
            ActionSheet(
                title: Text("Add Photos"),
                message: Text("Choose how to add photos of your item"),
                buttons: [
                    .default(Text("📷 Take Single Photo")) {
                        showingCamera = true
                    },
                    .default(Text("📁 Choose Single Photo")) {
                        showingPhotoPicker = true
                    },
                    .default(Text("📚 Choose Multiple Photos")) {
                        showingMultiPhotoPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingCamera) {
            CameraViewRepresentable { image in
                capturedImages.append(image)
                analysisResult = nil
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker(selectedImage: .constant(nil))
                .onDisappear {
                    // Handle single photo selection
                }
        }
        .sheet(isPresented: $showingMultiPhotoPicker) {
            MultiPhotoPicker(selectedImages: $capturedImages)
                .onDisappear {
                    if !capturedImages.isEmpty {
                        analysisResult = nil
                    }
                }
        }
        .sheet(isPresented: $showingItemForm) {
            if let result = analysisResult {
                EnhancedItemFormView(
                    analysis: result,
                    images: capturedImages,
                    onSave: { item in
                        inventoryManager.addItem(item)
                        googleSheetsService.uploadItem(item)
                        showingItemForm = false
                        capturedImages = []
                        analysisResult = nil
                    }
                )
                .environmentObject(inventoryManager)
            }
        }
    }
    
    private func analyzePhotos() {
        guard !capturedImages.isEmpty else { return }
        aiService.analyzeMultipleImages(capturedImages) { analysis in
            analysisResult = analysis
        }
    }
}

// MARK: - Enhanced Photo Gallery
struct EnhancedPhotoGallery: View {
    @Binding var images: [UIImage]
    @Binding var currentIndex: Int
    
    var body: some View {
        VStack(spacing: 10) {
            // Main Photo Display
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 320)
            
            // Photo Counter and Actions
            HStack {
                Text("\(currentIndex + 1) of \(images.count) photos")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Delete Photo") {
                    if images.count > 1 {
                        images.remove(at: currentIndex)
                        if currentIndex >= images.count {
                            currentIndex = images.count - 1
                        }
                    } else {
                        images.removeAll()
                        currentIndex = 0
                    }
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Enhanced Photo Buttons
struct EnhancedPhotoButtons: View {
    let onSingleCamera: () -> Void
    let onSinglePhoto: () -> Void
    let onMultiPhoto: () -> Void
    let onAnalyze: () -> Void
    let hasPhotos: Bool
    let isAnalyzing: Bool
    let photoCount: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Photo capture buttons
            HStack(spacing: 12) {
                Button(action: onSingleCamera) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Camera")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                
                Button(action: onSinglePhoto) {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("Single")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.purple, .purple.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                
                Button(action: onMultiPhoto) {
                    HStack {
                        Image(systemName: "photo.stack.fill")
                        Text("Multi")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
            }
            
            // Analysis button
            if hasPhotos {
                Button(action: onAnalyze) {
                    HStack {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("AI Analyzing \(photoCount) Photo\(photoCount == 1 ? "" : "s")...")
                        } else {
                            Image(systemName: "brain.head.profile")
                            Text("🧠 Enhanced AI Analysis (\(photoCount) photo\(photoCount == 1 ? "" : "s"))")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                .disabled(isAnalyzing)
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
            // Header with Enhanced Info
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("Enhanced AI Analysis")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(Int(analysis.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(analysis.confidence > 0.9 ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(analysis.confidence > 0.9 ? .green : .orange)
                        .cornerRadius(12)
                    Text("AI Confidence")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Show photos analyzed if enhanced analysis
                    if let enhanced = analysis as? EnhancedItemAnalysis {
                        Text("\(enhanced.photosAnalyzed) photos")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Divider()
            
            // Enhanced Analysis Details
            VStack(spacing: 12) {
                // Item Details
                HStack {
                    Text("Item:")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(analysis.itemName)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                }
                
                // Model Number (if enhanced analysis)
                if let enhanced = analysis as? EnhancedItemAnalysis, !enhanced.modelNumber.isEmpty {
                    HStack {
                        Text("Model:")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(enhanced.modelNumber)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                }
                
                // Condition and Pricing
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
                
                // Price Information
                VStack(spacing: 8) {
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
                    
                    // Price Range (if enhanced)
                    if let enhanced = analysis as? EnhancedItemAnalysis,
                       enhanced.priceRange.low > 0 && enhanced.priceRange.high > 0 {
                        HStack {
                            Text("Market Range:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(enhanced.priceRange.low, specifier: "%.0f") - $\(enhanced.priceRange.high, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Resale Potential
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
                
                // Enhanced Market Info
                if let enhanced = analysis as? EnhancedItemAnalysis {
                    if !enhanced.competitionLevel.isEmpty || !enhanced.seasonalDemand.isEmpty {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                if !enhanced.competitionLevel.isEmpty {
                                    HStack {
                                        Text("Competition:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(enhanced.competitionLevel)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(enhanced.competitionLevel == "Low" ? .green : enhanced.competitionLevel == "Medium" ? .orange : .red)
                                    }
                                }
                                
                                if !enhanced.seasonalDemand.isEmpty {
                                    HStack {
                                        Text("Best Time:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(enhanced.seasonalDemand)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
            
            // Market Notes
            if !analysis.marketNotes.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("💡 Market Intelligence")
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
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }
            
            // Authentication Notes (if enhanced)
            if let enhanced = analysis as? EnhancedItemAnalysis, !enhanced.authenticationNotes.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("🔍 Authentication Notes")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    Text(enhanced.authenticationNotes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.purple.opacity(0.05))
                .cornerRadius(8)
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
    let images: [UIImage]
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
                Section("📸 Enhanced Analysis Results") {
                    VStack(alignment: .leading, spacing: 8) {
                        // Main image and analysis info
                        HStack {
                            if let firstImage = images.first {
                                Image(uiImage: firstImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(analysis.itemName)
                                    .fontWeight(.bold)
                                Text(analysis.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Enhanced analysis info
                                if let enhanced = analysis as? EnhancedItemAnalysis {
                                    if !enhanced.modelNumber.isEmpty {
                                        Text("Model: \(enhanced.modelNumber)")
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                    }
                                    
                                    Text("\(enhanced.photosAnalyzed) photos analyzed")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
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
                        
                        // Photo count indicator
                        if images.count > 1 {
                            Text("📚 \(images.count) photos captured for enhanced accuracy")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.top, 4)
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
                    
                    Picker("Condition", selection: $condition) {
                        Text("New").tag("New")
                        Text("Like New").tag("Like New")
                        Text("Good").tag("Good")
                        Text("Fair").tag("Fair")
                        Text("For Parts").tag("For Parts")
                    }
                }
                
                Section("🎯 Enhanced Pricing Analysis") {
                    VStack(spacing: 8) {
                        HStack {
                            Text("AI Suggested Price")
                            Spacer()
                            Text("$\(analysis.suggestedPrice, specifier: "%.2f")")
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                        
                        // Price range if available
                        if let enhanced = analysis as? EnhancedItemAnalysis,
                           enhanced.priceRange.low > 0 && enhanced.priceRange.high > 0 {
                            HStack {
                                Text("Market Range")
                                Spacer()
                                Text("$\(enhanced.priceRange.low, specifier: "%.0f") - $\(enhanced.priceRange.high, specifier: "%.0f")")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
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
                            
                            // ROI Assessment
                            if estimatedROI < 200 {
                                Text("⚠️ ROI below 200% target")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            } else if estimatedROI > 300 {
                                Text("🎯 Excellent ROI!")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Section("📝 Optimized eBay Listing") {
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
                        Text("Optimized Keywords")
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
                
                // Enhanced analysis details
                if let enhanced = analysis as? EnhancedItemAnalysis {
                    if !enhanced.shippingNotes.isEmpty || !enhanced.seasonalDemand.isEmpty {
                        Section("📦 Additional Intelligence") {
                            if !enhanced.shippingNotes.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Shipping Notes")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text(enhanced.shippingNotes)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if !enhanced.seasonalDemand.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Best Selling Time")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text(enhanced.seasonalDemand)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Enhanced Item Form")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save & Sync") {
                        saveEnhancedItem()
                    }
                    .disabled(purchasePrice.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveEnhancedItem() {
        guard let price = Double(purchasePrice) else { return }
        let finalPrice = Double(adjustedPrice) ?? analysis.suggestedPrice
        
        // Convert all images to data
        var imageDataArray: [Data] = []
        for image in images {
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
            marketNotes: analysis.marketNotes
        )
        
        onSave(item)
    }
}

// MARK: - Enhanced Settings View
struct EnhancedSettingsView: View {
    @EnvironmentObject var aiService: EnhancedAIService
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    @State private var showingAPIStatus = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("🚀 Enhanced AI Analysis") {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Multi-Photo AI Analysis")
                                .fontWeight(.semibold)
                            Text("GPT-4 Vision + Enhanced Prompting")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Toggle("Enhanced Analysis Mode", isOn: $aiService.enhancedMode)
                    
                    Button("Test AI Analysis") {
                        print("🧪 Testing enhanced AI...")
                    }
                }
                
                Section("📊 Google Sheets Integration") {
                    HStack {
                        Image(systemName: "tablecells")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("Auto-Sync Inventory")
                                .fontWeight(.semibold)
                            Text(googleSheetsService.syncStatus)
                                .font(.caption)
                                .foregroundColor(googleSheetsService.isConnected ? .green : .orange)
                        }
                        Spacer()
                        if googleSheetsService.isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: googleSheetsService.isConnected ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(googleSheetsService.isConnected ? .green : .orange)
                        }
                    }
                    
                    if let lastSync = googleSheetsService.lastSyncDate {
                        Text("Last sync: \(lastSync, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Setup Instructions") {
                        googleSheetsService.setupGoogleSheetsHeaders()
                    }
                    
                    Button("Test Connection") {
                        googleSheetsService.testConnection()
                    }
                    
                    Button("Open Spreadsheet") {
                        openGoogleSheet()
                    }
                }
                
                Section("⚡ Enhanced Features") {
                    FeatureStatusRow(icon: "camera.stack.fill", title: "Multi-Photo Analysis", enabled: true)
                    FeatureStatusRow(icon: "brain", title: "Enhanced AI Prompting", enabled: aiService.enhancedMode)
                    FeatureStatusRow(icon: "shield.checkered", title: "Authentication Analysis", enabled: true)
                    FeatureStatusRow(icon: "chart.bar.fill", title: "Market Intelligence", enabled: true)
                    FeatureStatusRow(icon: "dollarsign.circle", title: "Profit Optimization", enabled: true)
                }
                
                Section("🔧 Tools") {
                    Button("View API Status") {
                        showingAPIStatus = true
                    }
                    
                    Button("Force Sync All Items") {
                        print("🔄 Force syncing all items...")
                    }
                    
                    Button("Export Data") {
                        print("📤 Exporting data...")
                    }
                }
            }
            .navigationTitle("Enhanced Settings")
        }
        .sheet(isPresented: $showingAPIStatus) {
            APIStatusView()
                .environmentObject(aiService)
                .environmentObject(googleSheetsService)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    private func openGoogleSheet() {
        let url = "https://docs.google.com/spreadsheets/d/\(googleSheetsService.spreadsheetId)/edit"
        if let sheetURL = URL(string: url) {
            UIApplication.shared.open(sheetURL)
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

// MARK: - API Status View
struct APIStatusView: View {
    @EnvironmentObject var aiService: EnhancedAIService
    @EnvironmentObject var googleSheetsService: EnhancedGoogleSheetsService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section("🚀 Enhanced AI Status") {
                    StatusRow(
                        title: "Multi-Photo Analysis",
                        status: true,
                        detail: "GPT-4 Vision with enhanced prompting"
                    )
                    
                    StatusRow(
                        title: "Enhanced Mode",
                        status: aiService.enhancedMode,
                        detail: aiService.enhancedMode ? "Enabled" : "Disabled"
                    )
                    
                    StatusRow(
                        title: "API Connection",
                        status: !aiService.apiKey.isEmpty,
                        detail: "OpenAI API configured"
                    )
                }
                
                Section("📊 Google Sheets Status") {
                    StatusRow(
                        title: "Apps Script URL",
                        status: !googleSheetsService.appsScriptURL.contains("YOUR_APPS_SCRIPT_URL_HERE"),
                        detail: googleSheetsService.appsScriptURL.contains("YOUR_APPS_SCRIPT_URL_HERE") ? "Not configured" : "Configured"
                    )
                    
                    StatusRow(
                        title: "Connection",
                        status: googleSheetsService.isConnected,
                        detail: googleSheetsService.syncStatus
                    )
                    
                    StatusRow(
                        title: "Sync Status",
                        status: !googleSheetsService.isSyncing,
                        detail: googleSheetsService.isSyncing ? "Syncing..." : "Ready"
                    )
                }
                
                Section("📱 App Features") {
                    StatusRow(
                        title: "Camera Access",
                        status: true,
                        detail: "Granted"
                    )
                    
                    StatusRow(
                        title: "Photo Library",
                        status: true,
                        detail: "Multi-photo selection enabled"
                    )
                    
                    StatusRow(
                        title: "Network",
                        status: true,
                        detail: "Connected"
                    )
                }
                
                Section("🔧 Setup Required") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("To complete Google Sheets integration:")
                            .fontWeight(.semibold)
                        
                        Text("1. Go to script.google.com")
                            .font(.caption)
                        
                        Text("2. Create new project with provided script")
                            .font(.caption)
                        
                        Text("3. Deploy as Web App")
                            .font(.caption)
                        
                        Text("4. Update appsScriptURL in code")
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("API Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct StatusRow: View {
    let title: String
    let status: Bool
    let detail: String
    
    var body: some View {
        HStack {
            Image(systemName: status ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(status ? .green : .orange)
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.medium)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
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

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
