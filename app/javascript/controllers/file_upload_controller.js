import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "label", "filename"]

  connect() {
    console.log("File upload controller connected")
  }

  updateFilename(event) {
    const input = event.target
    const files = input.files
    
    if (files.length > 0) {
      const filename = files[0].name
      const filesize = this.formatFileSize(files[0].size)
      
      // Update the label text to show the filename
      if (this.hasFilenameTarget) {
        this.filenameTarget.textContent = `${filename} (${filesize})`
        this.filenameTarget.classList.remove('hidden')
      }
      
      // Update the label styling to indicate a file is selected
      if (this.hasLabelTarget) {
        this.labelTarget.classList.add('text-seller-700', 'font-semibold')
      }
    } else {
      // Reset if no file selected
      if (this.hasFilenameTarget) {
        this.filenameTarget.classList.add('hidden')
      }
      if (this.hasLabelTarget) {
        this.labelTarget.classList.remove('text-seller-700', 'font-semibold')
      }
    }
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
  }
}
