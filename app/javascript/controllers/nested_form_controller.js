import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container"]

  add(event) {
    event.preventDefault()
    
    // Get template content and replace the placeholder ID
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    
    // Insert the new fields before the end of the container
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    
    const item = event.target.closest(".nested-fields")
    
    // Check if this is a new or existing record
    const hiddenInput = item.querySelector('input[name*="_destroy"]')
    
    if (hiddenInput) {
      // Mark existing record for destruction
      hiddenInput.value = 1
      item.style.display = 'none'
    } else {
      // Simply remove new record from the DOM
      item.remove()
    }
  }
}