// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "icon", "form"]

  connect() {
    // For debugging - remove in production
    console.log("Search controller connected")
    // Register the form as the parent of the input if it exists
    if (!this.hasFormTarget && this.inputTarget) {
      // If form target isn't found, use the closest form element
      this.formTargetValue = this.inputTarget.closest('form')
    }
  }

  // Submit form when Enter key is pressed
  input_keypress(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.submitForm()
    }
  }

  // Handle debounced input for auto-search
  input_input() {
    clearTimeout(this.timeout)
    if (this.inputTarget.value.trim().length >= 3) {
      this.timeout = setTimeout(() => {
        this.submitForm()
      }, 500)
    }
  }

  // Handle search icon click
  handleIconClick(event) {
    event.preventDefault()
    if (this.inputTarget.value.trim() !== '') {
      this.submitForm()
    } else {
      this.inputTarget.focus()
    }
  }

  // Submit the form
  submitForm() {
    // Using hasFormTarget to check if the form target exists
    if (this.hasFormTarget) {
      this.formTarget.submit()
    } else if (this.inputTarget) {
      // Fallback to finding the form via the closest parent
      const form = this.inputTarget.closest('form')
      if (form) {
        form.submit()
      } else {
        console.error("Could not find form to submit")
      }
    }
  }
}