// app/javascript/barcode_scanner.js

// Global instance to manage the reader across the application
let codeReader = null;

// Function to start the scanner
function startScanner() {
  console.log("Starting scanner function called");
  
  // Get elements
  const videoElem = document.getElementById('scanner-video');
  const barcodeInput = document.getElementById('barcode-result');
  
  if (!videoElem || !barcodeInput) {
    console.log("Scanner elements not found on page");
    return;
  }
  
  console.log("Scanner elements found, initializing camera...");
  
  // Ensure ZXing is loaded
  if (typeof ZXing === 'undefined') {
    console.error("ZXing library not loaded! Please check script inclusion.");
    return;
  }
  
  // Initialize scanner if not already initialized
  if (!codeReader) {
    codeReader = new ZXing.BrowserMultiFormatReader();
  }
  
  // Show video element
  videoElem.style.display = 'block';
  
  // Start camera immediately
  codeReader.decodeFromVideoDevice(null, videoElem, (result) => {
    if (result) {
      console.log("Barcode detected:", result.text);
      barcodeInput.value = result.text;
      codeReader.reset();
      videoElem.style.display = 'none';
      
      // Find and click the submit button
      const submitButton = document.querySelector("input[type='submit']");
      if (submitButton) {
        submitButton.click();
      }
    }
  }).catch(err => {
    console.error("Camera error:", err);
  });
}

// Function to stop the scanner
function stopScanner() {
  if (codeReader) {
    console.log("Stopping scanner");
    codeReader.reset();
    // Don't set to null to allow reuse
  }
}

// Keep these for Turbo/Turbolinks events
document.addEventListener('turbo:load', function() {
  console.log("Turbo load event fired");
  setTimeout(startScanner, 200); // Slightly longer timeout
});

document.addEventListener('turbolinks:load', function() {
  console.log("Turbolinks load event fired");
  setTimeout(startScanner, 200); // Slightly longer timeout
});

// Change the window load event to be more robust
window.addEventListener('load', function() {
  console.log("Window load event fired");
  setTimeout(startScanner, 300); // Slightly longer timeout
});

// Handle page navigation away
document.addEventListener('turbo:before-visit', stopScanner);
document.addEventListener('turbolinks:before-visit', stopScanner);

// Expose functions globally
window.startBarcodeScanner = startScanner;
window.stopBarcodeScanner = stopScanner;