import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column"]

  connect() {
    this.initializeDragAndDrop()
  }

  initializeDragAndDrop() {
    // Add drag event listeners to all deal cards
    this.updateDraggableCards()
    
    // Make columns droppable
    this.columnTargets.forEach(column => {
      column.addEventListener('dragover', this.handleDragOver.bind(this))
      column.addEventListener('drop', this.handleDrop.bind(this))
      column.addEventListener('dragleave', this.handleDragLeave.bind(this))
    })
  }

  updateDraggableCards() {
    const cards = this.element.querySelectorAll('[data-deal-id]')
    
    cards.forEach(card => {
      card.setAttribute('draggable', 'true')
      card.addEventListener('dragstart', this.handleDragStart.bind(this))
      card.addEventListener('dragend', this.handleDragEnd.bind(this))
    })
  }

  handleDragStart(event) {
    const card = event.currentTarget
    const dealId = card.dataset.dealId
    const currentStatus = card.dataset.dealStatus
    
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', dealId)
    event.dataTransfer.setData('currentStatus', currentStatus)
    
    // Add visual feedback
    card.classList.add('opacity-50', 'scale-95')
    
    // Store reference to dragged element
    this.draggedCard = card
  }

  handleDragEnd(event) {
    const card = event.currentTarget
    card.classList.remove('opacity-50', 'scale-95')
    
    // Remove drag-over styling from all columns
    this.columnTargets.forEach(column => {
      column.classList.remove('bg-blue-50', 'border-blue-300')
    })
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
    
    const column = event.currentTarget
    column.classList.add('bg-blue-50', 'border-2', 'border-blue-300', 'rounded-lg')
  }

  handleDragLeave(event) {
    const column = event.currentTarget
    
    // Only remove styling if we're actually leaving the column
    if (!column.contains(event.relatedTarget)) {
      column.classList.remove('bg-blue-50', 'border-blue-300')
    }
  }

  async handleDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const column = event.currentTarget
    const newStatus = column.dataset.status
    const dealId = event.dataTransfer.getData('text/plain')
    const currentStatus = event.dataTransfer.getData('currentStatus')
    
    // Remove drag-over styling
    column.classList.remove('bg-blue-50', 'border-blue-300')
    
    // Don't do anything if dropped in same column
    if (newStatus === currentStatus) {
      return
    }
    
    // Validate forward movement
    if (!this.canMoveToStatus(currentStatus, newStatus)) {
      this.showError('Mouvement arrière non autorisé')
      return
    }
    
    // Send request to move deal
    try {
      const response = await fetch(`/buyer/deals/${dealId}/move_stage`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken(),
          'Accept': 'text/vnd.turbo-stream.html'
        },
        body: JSON.stringify({ new_status: newStatus })
      })
      
      if (response.ok) {
        // Turbo Stream will handle the DOM updates
        const text = await response.text()
        Turbo.renderStreamMessage(text)
      } else {
        this.showError('Erreur lors du déplacement du deal')
      }
    } catch (error) {
      console.error('Error moving deal:', error)
      this.showError('Erreur de connexion')
    }
  }

  canMoveToStatus(currentStatus, newStatus) {
    const statusOrder = [
      'favorited',
      'to_contact',
      'info_exchange',
      'analysis',
      'project_alignment',
      'negotiation',
      'loi',
      'audits',
      'financing',
      'signed'
    ]
    
    const currentIndex = statusOrder.indexOf(currentStatus)
    const newIndex = statusOrder.indexOf(newStatus)
    
    // Can't move to released or abandoned via drag
    if (newStatus === 'released' || newStatus === 'abandoned') {
      return false
    }
    
    // Only allow forward movement
    return newIndex >= currentIndex
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.content : ''
  }

  showError(message) {
    // Simple error notification
    const notification = document.createElement('div')
    notification.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-fade-in'
    notification.textContent = message
    
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.classList.add('animate-fade-out')
      setTimeout(() => notification.remove(), 300)
    }, 3000)
  }
}
