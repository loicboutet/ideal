import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["messages", "form", "input"]
  static values = {
    conversationId: Number,
    currentUserId: Number
  }

  connect() {
    console.log("Conversation controller connected!")
    console.log("Conversation ID:", this.conversationIdValue)
    console.log("Current User ID:", this.currentUserIdValue)
    
    if (this.hasConversationIdValue) {
      this.subscribeToChannel()
      this.scrollToBottom()
    }
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "ConversationChannel",
        conversation_id: this.conversationIdValue
      },
      {
        connected: () => {
          console.log("Connected to ConversationChannel")
        },

        disconnected: () => {
          console.log("Disconnected from ConversationChannel")
        },

        received: (data) => {
          console.log("Received message data:", data)
          this.appendMessageFromData(data)
          this.scrollToBottom()
        }
      }
    )
  }

  submitMessage(event) {
    event.preventDefault()
    
    const messageBody = this.inputTarget.value.trim()
    
    if (messageBody === "") {
      return
    }

    // Send via Action Cable
    if (this.subscription) {
      this.subscription.perform("speak", {
        message: messageBody,
        conversation_id: this.conversationIdValue
      })
      
      // Add optimistic message to sender's view
      this.addOptimisticMessage(messageBody)
    }

    // Clear the input field
    this.inputTarget.value = ""
    
    // Scroll to bottom
    this.scrollToBottom()
  }
  
  addOptimisticMessage(messageBody) {
    // Create a temporary message element for the sender
    const messageDiv = document.createElement('div')
    messageDiv.className = 'flex items-start gap-3 justify-end'
    messageDiv.dataset.optimistic = 'true'
    
    const now = new Date()
    const timeString = now.toLocaleString('fr-FR', { 
      year: 'numeric',
      month: '2-digit', 
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
    
    messageDiv.innerHTML = `
      <div class="flex-1 flex flex-col items-end">
        <div class="bg-orange-600 text-white rounded-lg p-3 max-w-lg">
          <p class="text-sm text-white">${this.escapeHtml(messageBody)}</p>
        </div>
        <span class="text-xs text-gray-500 mt-1 block">
          ${timeString}
        </span>
      </div>
      <div class="w-8 h-8 bg-gradient-to-br from-green-500 to-green-600 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
        C
      </div>
    `
    
    this.messagesTarget.appendChild(messageDiv)
  }
  
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  appendMessageFromData(data) {
    if (!this.hasMessagesTarget) return
    
    // Remove any optimistic messages first
    const optimisticMessages = this.messagesTarget.querySelectorAll('[data-optimistic="true"]')
    optimisticMessages.forEach(msg => msg.remove())
    
    // Check if message already exists
    const existingMessage = this.messagesTarget.querySelector(`[data-message-id="${data.id}"]`)
    if (existingMessage) return
    
    // Determine if current user is the sender
    const isSender = data.sender_id === this.currentUserIdValue
    
    // Format the timestamp
    const createdAt = new Date(data.created_at)
    const timeString = createdAt.toLocaleString('fr-FR', { 
      year: 'numeric',
      month: '2-digit', 
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
    
    // Create the message element
    const messageDiv = document.createElement('div')
    messageDiv.className = `flex items-start gap-3 ${isSender ? 'justify-end' : ''}`
    messageDiv.dataset.messageId = data.id
    
    if (isSender) {
      // Sender view: right-aligned, orange background
      messageDiv.innerHTML = `
        <div class="flex-1 flex flex-col items-end">
          <div class="bg-orange-600 text-white rounded-lg p-3 max-w-lg">
            <p class="text-sm text-white">${this.escapeHtml(data.body)}</p>
          </div>
          <span class="text-xs text-gray-500 mt-1 block">
            ${timeString}
          </span>
        </div>
        <div class="w-8 h-8 bg-gradient-to-br from-green-500 to-green-600 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
          ${data.sender_initial}
        </div>
      `
    } else {
      // Receiver view: left-aligned, gray background
      messageDiv.innerHTML = `
        <div class="w-8 h-8 bg-gradient-to-br from-orange-500 to-red-600 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
          ${data.sender_initial}
        </div>
        <div class="flex-1">
          <div class="bg-gray-100 rounded-lg p-3 max-w-lg">
            <p class="text-sm text-gray-900">${this.escapeHtml(data.body)}</p>
          </div>
          <span class="text-xs text-gray-500 mt-1 block">
            ${timeString}
          </span>
        </div>
      `
    }
    
    this.messagesTarget.appendChild(messageDiv)
  }

  appendMessage(messageHtml) {
    if (this.hasMessagesTarget) {
      // Remove any optimistic messages first
      const optimisticMessages = this.messagesTarget.querySelectorAll('[data-optimistic="true"]')
      optimisticMessages.forEach(msg => msg.remove())
      
      // Check if message already exists (by data-message-id)
      const tempDiv = document.createElement('div')
      tempDiv.innerHTML = messageHtml
      const messageElement = tempDiv.firstElementChild
      const messageId = messageElement.getAttribute('data-message-id')
      
      const existingMessage = this.messagesTarget.querySelector(`[data-message-id="${messageId}"]`)
      
      if (!existingMessage) {
        this.messagesTarget.insertAdjacentHTML('beforeend', messageHtml)
      }
    }
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }
}
