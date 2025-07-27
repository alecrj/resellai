import SwiftUI
import Foundation
import PhotosUI

// MARK: - API Configuration
struct APIConfig {
    static let openAIKey = "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"
    static let spreadsheetID = "1HLNiNBfIqLeIDfNTsEOkl5oPd0McUQGaCaL3cPOobLA"
    static let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    // Replace with your Google Apps Script URL
    static let googleAppsScriptURL = "https://script.google.com/macros/s/AKfycbztiFfbkCag9QghCX6nTmqI27LgtRSQZPgV4VvJJIMOiepedYlRvRnjhyF0x6i-sS_4Ew/exec"
}

// MARK: - Enhanced AI Service with Multi-Photo Support
class EnhancedAIService: ObservableObject {
    @Published var apiKey = APIConfig.openAIKey
    @Published var enhancedMode = true
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    
    // Single photo analysis (backwards compatible)
    func analyzeImage(_ image: UIImage, completion: @escaping (ItemAnalysis) -> Void) {
        analyzeMultipleImages([image], completion: completion)
    }
    
    // NEW: Multi-photo analysis
    func analyzeMultipleImages(_ images: [UIImage], completion: @escaping (ItemAnalysis) -> Void) {
        isAnalyzing = true
        analysisProgress = "Processing \(images.count) photo\(images.count == 1 ? "" : "s")..."
        
        // Convert images to base64
        var base64Images: [String] = []
        for image in images {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                base64Images.append(imageData.base64EncodedString())
            }
        }
        
        guard !base64Images.isEmpty else {
            provideFallbackAnalysis(completion: completion)
            return
        }
        
        // ENHANCED MULTI-PHOTO PROMPT
        let prompt = """
        You are an expert eBay reseller analyzing \(images.count) photo\(images.count == 1 ? "" : "s") of an item. Provide the most accurate identification and pricing possible.

        🎯 MULTI-PHOTO ANALYSIS STRATEGY:
        \(images.count > 1 ? """
        - Photo 1: Overall item identification and condition assessment
        - Additional Photos: Look for tags, labels, model numbers, serial numbers, authenticity markers
        - Cross-reference details between photos for maximum accuracy
        """ : "- Analyze this single photo for all available details")
        
        📍 CRITICAL IDENTIFICATION REQUIREMENTS:
        - Read ALL visible text completely (brand names, model numbers, SKUs, size tags)
        - Identify exact model/style codes, UPC codes, serial numbers if visible
        - Determine specific colorways, sizes, editions, production years
        - Look for authenticity markers (holograms, tags, fonts, stitching patterns)
        - Assess condition impact on value (wear, damage, completeness)
        
        💰 PRICING INTELLIGENCE:
        - Base prices on recent eBay sold listings knowledge (last 30 days)
        - Consider condition impact (New vs Used pricing difference)
        - Factor in rarity, demand trends, seasonal considerations
        - Include authentication premiums for luxury/collectible items
        - Account for regional market variations
        
        🎯 EXCELLENCE EXAMPLES:
        ❌ "Nike Shoes" → ✅ "Nike Air Jordan 1 Retro High OG 'Chicago' 2015 555088-101 Size 10.5"
        ❌ "Designer Bag" → ✅ "Louis Vuitton Neverfull MM Damier Ebene N51105 Date Code VI4129"
        ❌ "Vintage Shirt" → ✅ "1990s Metallica Master of Puppets Tour T-Shirt XL Single Stitch USA"
        
        Respond ONLY in this JSON format:
        {
            "itemName": "exact specific identification with model/details",
            "brand": "brand name if visible",
            "modelNumber": "specific model/SKU/style code found",
            "category": "precise eBay category path",
            "suggestedPrice": 0.00,
            "priceRange": {"low": 0.00, "high": 0.00, "average": 0.00},
            "confidence": 0.95,
            "ebayTitle": "optimized 80-char SEO title with key terms",
            "description": "detailed professional description with measurements/flaws",
            "keywords": ["primary", "secondary", "brand", "model", "size", "color"],
            "condition": "New/Like New/Excellent/Good/Fair/Poor",
            "resalePotential": 8,
            "marketNotes": "recent market trends and timing insights",
            "authenticationNotes": "authenticity markers observed or concerns",
            "shippingNotes": "size/weight/fragility considerations",
            "competitionLevel": "Low/Medium/High",
            "seasonalDemand": "optimal selling timing and seasonal factors",
            "photosAnalyzed": \(images.count)
        }
        """
        
        analysisProgress = "Connecting to AI..."
        
        // Create multi-image payload
        var imageContent: [[String: Any]] = []
        
        // Add text prompt
        imageContent.append([
            "type": "text",
            "text": prompt
        ])
        
        // Add all images
        for base64Image in base64Images {
            imageContent.append([
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(base64Image)",
                    "detail": "high"
                ]
            ])
        }
        
        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an expert eBay reseller with perfect knowledge of current market values, authentication, and pricing trends."
                ],
                [
                    "role": "user",
                    "content": imageContent
                ]
            ],
            "max_tokens": 1500,
            "temperature": 0.05 // Ultra-low for consistency
        ]
        
        analysisProgress = "AI analyzing photos..."
        
        var request = URLRequest(url: URL(string: APIConfig.openAIEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Error creating request: \(error)")
            provideFallbackAnalysis(completion: completion)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                self?.analysisProgress = "Ready"
            }
            
            if let error = error {
                print("❌ API Error: \(error)")
                self?.provideFallbackAnalysis(completion: completion)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                self?.provideFallbackAnalysis(completion: completion)
                return
            }
            
            self?.parseEnhancedResponse(data, photosCount: images.count, completion: completion)
        }.resume()
    }
    
    private func parseEnhancedResponse(_ data: Data, photosCount: Int, completion: @escaping (ItemAnalysis) -> Void) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                print("🤖 Enhanced AI Response: \(content.prefix(500))...")
                
                // Clean JSON content
                var cleanContent = content
                if content.contains("```json") {
                    cleanContent = content
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if let jsonData = cleanContent.data(using: .utf8),
                   let itemData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    
                    // Extract price range
                    var priceRange = PriceRange()
                    if let range = itemData["priceRange"] as? [String: Any] {
                        priceRange.low = range["low"] as? Double ?? 0
                        priceRange.high = range["high"] as? Double ?? 0
                        priceRange.average = range["average"] as? Double ?? 0
                    }
                    
                    let analysis = EnhancedItemAnalysis(
                        itemName: itemData["itemName"] as? String ?? "Unknown Item",
                        category: itemData["category"] as? String ?? "Other",
                        modelNumber: itemData["modelNumber"] as? String ?? "",
                        suggestedPrice: itemData["suggestedPrice"] as? Double ?? 10.0,
                        priceRange: priceRange,
                        confidence: itemData["confidence"] as? Double ?? 0.5,
                        ebayTitle: itemData["ebayTitle"] as? String ?? "Item for Sale",
                        description: itemData["description"] as? String ?? "Item in good condition",
                        keywords: itemData["keywords"] as? [String] ?? ["item"],
                        condition: itemData["condition"] as? String ?? "Good",
                        resalePotential: itemData["resalePotential"] as? Int ?? 5,
                        marketNotes: itemData["marketNotes"] as? String ?? "",
                        authenticationNotes: itemData["authenticationNotes"] as? String ?? "",
                        shippingNotes: itemData["shippingNotes"] as? String ?? "",
                        competitionLevel: itemData["competitionLevel"] as? String ?? "Medium",
                        seasonalDemand: itemData["seasonalDemand"] as? String ?? "",
                        photosAnalyzed: itemData["photosAnalyzed"] as? Int ?? photosCount
                    )
                    
                    print("✅ Enhanced analysis complete: \(analysis.itemName)")
                    
                    DispatchQueue.main.async {
                        completion(analysis)
                    }
                } else {
                    print("❌ Failed to parse enhanced JSON")
                    self.parseBasicResponse(cleanContent, completion: completion)
                }
            } else {
                print("❌ Unexpected API response structure")
                self.provideFallbackAnalysis(completion: completion)
            }
        } catch {
            print("❌ Error parsing enhanced response: \(error)")
            self.provideFallbackAnalysis(completion: completion)
        }
    }
    
    private func parseBasicResponse(_ content: String, completion: @escaping (ItemAnalysis) -> Void) {
        let analysis = BasicItemAnalysis(
            itemName: extractBasicInfo(from: content, key: "itemName") ?? "AI Analyzed Item",
            category: extractBasicInfo(from: content, key: "category") ?? "General",
            suggestedPrice: Double(extractBasicInfo(from: content, key: "suggestedPrice") ?? "20") ?? 20.0,
            confidence: 0.7,
            ebayTitle: extractBasicInfo(from: content, key: "ebayTitle") ?? "Item for Sale",
            description: content,
            keywords: ["analyzed", "item", "resale"],
            condition: extractBasicInfo(from: content, key: "condition") ?? "Good",
            resalePotential: 6,
            marketNotes: "Basic analysis completed"
        )
        
        DispatchQueue.main.async {
            completion(analysis)
        }
    }
    
    private func extractBasicInfo(from text: String, key: String) -> String? {
        let pattern = "\"\(key)\":\\s*\"([^\"]*)\""
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)
        
        if let match = regex?.firstMatch(in: text, range: range),
           let valueRange = Range(match.range(at: 1), in: text) {
            return String(text[valueRange])
        }
        return nil
    }
    
    private func provideFallbackAnalysis(completion: @escaping (ItemAnalysis) -> Void) {
        DispatchQueue.main.async {
            let fallback = BasicItemAnalysis(
                itemName: "Unidentified Item",
                category: "Other",
                suggestedPrice: 15.0,
                confidence: 0.3,
                ebayTitle: "Item for Sale - See Photos",
                description: "Please see photos for condition and details. Research recommended for accurate pricing.",
                keywords: ["item", "sale", "resale"],
                condition: "Good",
                resalePotential: 5,
                marketNotes: "Manual analysis recommended"
            )
            completion(fallback)
        }
    }
}

// MARK: - Enhanced Google Sheets Service (Fixed)
class EnhancedGoogleSheetsService: ObservableObject {
    @Published var spreadsheetId = APIConfig.spreadsheetID
    @Published var isConnected = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus = "Ready"
    @Published var appsScriptURL = APIConfig.googleAppsScriptURL
    
    func authenticate() {
        print("🔐 Setting up Google Apps Script connection...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isConnected = !self.appsScriptURL.contains("YOUR_APPS_SCRIPT_URL_HERE")
            self.syncStatus = self.isConnected ? "Connected" : "Setup Required"
            print(self.isConnected ? "✅ Apps Script ready" : "⚠️ Apps Script URL needed")
        }
    }
    
    func testConnection() {
        guard !appsScriptURL.contains("YOUR_APPS_SCRIPT_URL_HERE") else {
            syncStatus = "Apps Script URL not configured"
            isConnected = false
            return
        }
        
        print("🧪 Testing Google Apps Script connection...")
        isSyncing = true
        syncStatus = "Testing..."
        
        guard let url = URL(string: appsScriptURL) else {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncStatus = "Invalid URL"
                self.isConnected = false
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isSyncing = false
                
                if let error = error {
                    print("❌ Connection test failed: \(error)")
                    self?.syncStatus = "Connection Failed"
                    self?.isConnected = false
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("✅ Google Apps Script connection successful!")
                        self?.syncStatus = "Connected"
                        self?.isConnected = true
                    } else {
                        print("❌ HTTP Error: \(httpResponse.statusCode)")
                        self?.syncStatus = "HTTP Error \(httpResponse.statusCode)"
                        self?.isConnected = false
                    }
                }
            }
        }.resume()
    }
    
    func uploadItem(_ item: InventoryItem) {
        guard !appsScriptURL.contains("YOUR_APPS_SCRIPT_URL_HERE") else {
            print("⚠️ Google Apps Script URL not configured")
            return
        }
        
        print("📤 Uploading to Google Sheets: \(item.name)")
        isSyncing = true
        syncStatus = "Uploading..."
        
        let itemData: [String: Any] = [
            "itemNumber": item.itemNumber,
            "name": item.name,
            "source": item.source,
            "purchasePrice": item.purchasePrice,
            "suggestedPrice": item.suggestedPrice,
            "status": item.status.rawValue,
            "profit": item.estimatedProfit,
            "roi": item.estimatedROI,
            "date": formatDate(item.dateAdded),
            "title": item.title,
            "description": item.description,
            "keywords": item.keywords.joined(separator: ", "),
            "condition": item.condition,
            "category": item.category
        ]
        
        guard let url = URL(string: appsScriptURL) else {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncStatus = "Invalid URL"
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: itemData)
        } catch {
            print("❌ Error creating request: \(error)")
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncStatus = "Request Error"
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isSyncing = false
                
                if let error = error {
                    print("❌ Upload failed: \(error)")
                    self?.syncStatus = "Upload Failed"
                    return
                }
                
                if let data = data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("📊 Apps Script Response: \(responseString)")
                    
                    if responseString.contains("success") {
                        print("✅ Item uploaded successfully: \(item.name)")
                        self?.syncStatus = "Synced"
                        self?.lastSyncDate = Date()
                        self?.isConnected = true
                    } else {
                        print("❌ Upload failed")
                        self?.syncStatus = "Upload Failed"
                    }
                } else {
                    self?.syncStatus = "No Response"
                }
            }
        }.resume()
    }
    
    func updateItem(_ item: InventoryItem) {
        uploadItem(item)
    }
    
    func syncAllItems(_ items: [InventoryItem]) {
        guard !items.isEmpty else { return }
        
        isSyncing = true
        syncStatus = "Syncing \(items.count) items..."
        
        let group = DispatchGroup()
        var successCount = 0
        
        for (index, item) in items.enumerated() {
            group.enter()
            
            DispatchQueue.global().asyncAfter(deadline: .now() + Double(index) * 0.5) {
                self.uploadItemSilent(item) { success in
                    if success { successCount += 1 }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.isSyncing = false
            self.lastSyncDate = Date()
            self.syncStatus = "Synced \(successCount)/\(items.count) items"
            print("✅ Sync complete: \(successCount)/\(items.count) items")
        }
    }
    
    private func uploadItemSilent(_ item: InventoryItem, completion: @escaping (Bool) -> Void) {
        let itemData: [String: Any] = [
            "itemNumber": item.itemNumber,
            "name": item.name,
            "source": item.source,
            "purchasePrice": item.purchasePrice,
            "suggestedPrice": item.suggestedPrice,
            "status": item.status.rawValue,
            "profit": item.estimatedProfit,
            "roi": item.estimatedROI,
            "date": formatDate(item.dateAdded),
            "title": item.title,
            "description": item.description,
            "keywords": item.keywords.joined(separator: ", "),
            "condition": item.condition,
            "category": item.category
        ]
        
        guard let url = URL(string: appsScriptURL) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: itemData)
        } catch {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let responseString = String(data: data, encoding: .utf8),
               responseString.contains("success") {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    func setupGoogleSheetsHeaders() {
        print("📋 Google Apps Script Setup Instructions:")
        print("1. Go to script.google.com")
        print("2. Create new project")
        print("3. Replace Code.gs with the provided script")
        print("4. Deploy as Web App (Execute as: Me, Access: Anyone)")
        print("5. Copy the deployment URL and update APIConfig.googleAppsScriptURL")
        print("📊 Sheet URL: https://docs.google.com/spreadsheets/d/\(spreadsheetId)/edit")
    }
}

// MARK: - Multi Photo Picker
struct MultiPhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5 // Allow up to 5 photos
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiPhotoPicker
        
        init(_ parent: MultiPhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        DispatchQueue.main.async {
                            if let uiImage = image as? UIImage {
                                self.parent.selectedImages.append(uiImage)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Photo Picker Helper (Single Photo)
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}
