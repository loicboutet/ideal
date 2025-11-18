import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="searchable-select"
export default class extends Controller {
  static values = {
    placeholder: String,
    allowClear: { type: Boolean, default: true }
  }

  connect() {
    console.log('Searchable select controller connected')
    console.log('Element:', this.element)
    console.log('Placeholder:', this.placeholderValue)
    
    // Wait for Tom Select to be available (loaded from CDN)
    this.waitForTomSelect()
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy()
    }
  }

  waitForTomSelect() {
    if (typeof window.TomSelect !== 'undefined') {
      console.log('TomSelect found, initializing...')
      setTimeout(() => {
        this.initializeTomSelect()
      }, 100)
    } else {
      console.log('Waiting for TomSelect to load...')
      setTimeout(() => this.waitForTomSelect(), 100)
    }
  }

  initializeTomSelect() {
    console.log('Initializing TomSelect...')
    console.log('TomSelect constructor:', window.TomSelect)
    
    try {
      const options = {
        plugins: ['clear_button'],
        placeholder: this.placeholderValue || 'Select an option...',
        allowEmptyOption: true,
        create: false,
        sortField: {
          field: "text",
          direction: "asc"
        },
        render: {
          no_results: function(data, escape) {
            return '<div class="no-results px-3 py-2 text-sm text-gray-500">No results found for "' + escape(data.input) + '"</div>';
          }
        },
        onInitialize: function() {
          // Add custom classes for Tailwind styling
          this.control.classList.add('ts-control-custom')
          console.log('TomSelect initialized successfully')
        }
      }

      this.tomSelect = new window.TomSelect(this.element, options)
      console.log('TomSelect instance created:', this.tomSelect)
    } catch (error) {
      console.error('Error initializing TomSelect:', error)
      console.error('Error stack:', error.stack)
    }
  }
}
