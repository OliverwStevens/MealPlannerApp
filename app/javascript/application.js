// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "barcode_scanner"
//import "../stylesheets/application.scss"
//import "@zxing/library";
import * as ZXing from "@zxing/library"
console.log("MINIMAL TEST - This should appear")

document.addEventListener("DOMContentLoaded", () => {
  console.log("DOM fully loaded")
})

document.addEventListener("turbo:load", () => {
  console.log("Turbo loaded a page")
})