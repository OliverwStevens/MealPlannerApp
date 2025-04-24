import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]
  
  connect() {
    // Optional: You can add initialization code here
    console.log("Mobile menu controller connected")
  }

  toggle() {
    this.menuTarget.classList.toggle('active')
  }

  hide(event) {
    // Hide menu when clicking outside
    if (!this.element.contains(event.target) && !this.menuTarget.contains(event.target)) {
      this.menuTarget.classList.remove('active')
    }
  }
}