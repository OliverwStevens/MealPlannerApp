// app/javascript/controllers/infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = { 
    url: String,
    page: { type: Number, default: 1 }
  }

  connect() {
    this.createObserver()
  }

  disconnect() {
    this.observer.disconnect()
  }

  createObserver() {
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting && this.paginationTarget && !this.paginationTarget.classList.contains("loading")) {
          this.loadMore()
        }
      })
    }, { rootMargin: '200px' })

    if (this.hasPaginationTarget) {
      this.observer.observe(this.paginationTarget)
    }
  }

  loadMore() {
    if (this.paginationTarget.classList.contains("loading")) return
    
    // Add loading state
    this.paginationTarget.classList.add("loading")
    
    // Visual feedback - add page indicator
    console.log(`Loading page ${this.pageValue + 1}...`)
    
    this.pageValue++
    
    // Handle both relative and absolute URLs
    let url
    try {
      // Try to create URL directly (works if urlValue is absolute)
      url = new URL(this.urlValue)
    } catch(e) {
      // If that fails, assume it's a relative path and prepend origin
      url = new URL(this.urlValue, window.location.origin)
    }
    
    url.searchParams.set('page', this.pageValue)
    
    // Add a timestamp to prevent caching
    url.searchParams.set('_', new Date().getTime())
    
    fetch(url)
      .then(response => response.text())
      .then(html => {
        this.paginationTarget.classList.remove("loading")
        const parser = new DOMParser()
        const doc = parser.parseFromString(html, 'text/html')
        
        // Get entries from the response
        const newEntries = doc.querySelector(`[data-infinite-scroll-target="entries"]`)
        
        if (newEntries && newEntries.children.length > 0) {
          // Add a data attribute to indicate which page these items belong to
          const newItems = Array.from(newEntries.children)
          newItems.forEach(item => {
            item.setAttribute('data-page', this.pageValue)
          })
          
          // Convert to HTML and insert
          const tempContainer = document.createElement('div')
          tempContainer.append(...newItems)
          this.entriesTarget.insertAdjacentHTML('beforeend', tempContainer.innerHTML)
          
          console.log(`Added ${newItems.length} items from page ${this.pageValue}`)
        } else {
          console.log(`No new items found on page ${this.pageValue}`)
        }
        
        // Check if there's still a pagination element in the response
        const newPagination = doc.querySelector(`[data-infinite-scroll-target="pagination"]`)
        if (!newPagination) {
          // No more pages
          this.observer.disconnect()
          this.paginationTarget.remove()
        }
      })
  }
}