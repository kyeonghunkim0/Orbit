//
//  ReceiptScannerView.swift
//  Orbit
//
//  Created by Orbit on 11/30/25.
//

import SwiftUI
import Vision
import VisionKit

struct ReceiptScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var recognizedText: String
    @Binding var scannedDate: Date
    @Binding var scannedAmount: Double
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ReceiptScannerView
        
        init(_ parent: ReceiptScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // Process the first page
            if scan.pageCount > 0 {
                let image = scan.imageOfPage(at: 0)
                processImage(image)
            }
            parent.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera error: \(error)")
            parent.dismiss()
        }
        
        private func processImage(_ image: UIImage) {
            guard let cgImage = image.cgImage else { return }
            
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                    return
                }
                
                let fullText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                
                DispatchQueue.main.async {
                    self?.parent.recognizedText = fullText
                    self?.parseReceiptText(fullText)
                }
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ko-KR", "en-US"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
        
        private func parseReceiptText(_ text: String) {
            let lines = text.components(separatedBy: "\n")
            
            // 1. Find Date
            // Patterns: YYYY-MM-DD, YYYY.MM.DD, YYYY/MM/DD
            let datePattern = #"(\d{4})[-./](\d{1,2})[-./](\d{1,2})"#
            if let regex = try? NSRegularExpression(pattern: datePattern),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                
                if let range = Range(match.range, in: text) {
                    let dateString = String(text[range])
                    let formatter = DateFormatter()
                    // Try common formats
                    let formats = ["yyyy-MM-dd", "yyyy.MM.dd", "yyyy/MM/dd"]
                    for format in formats {
                        formatter.dateFormat = format
                        if let date = formatter.date(from: dateString) {
                            parent.scannedDate = date
                            break
                        }
                    }
                }
            }
            
            // 2. Find Amount
            // Look for lines with currency symbols or numbers, usually at the bottom or labeled "Total", "합계"
            // Simple heuristic: look for the largest number that looks like a price
            var maxAmount: Double = 0
            
            for line in lines {
                // Remove non-numeric characters except dot and comma
                let cleanedLine = line.replacingOccurrences(of: "[^0-9.,]", with: "", options: .regularExpression)
                
                // Try to parse as Double (handling comma as thousands separator)
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                
                if let number = numberFormatter.number(from: cleanedLine) {
                    let value = number.doubleValue
                    // Filter out unlikely values (e.g. phone numbers, dates parsed as numbers)
                    // Assuming receipt total is likely the largest value found
                    if value > maxAmount && value < 100_000_000 { // Cap at 100M to avoid parsing barcodes/phone nums
                        maxAmount = value
                    }
                }
            }
            
            if maxAmount > 0 {
                parent.scannedAmount = maxAmount
            }
        }
    }
}
