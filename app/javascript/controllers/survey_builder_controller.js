import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="survey-builder"
export default class extends Controller {
  static targets = ["typeInput", "questionsSection", "questionsList", "questionsInput"]
  
  connect() {
    this.questionCount = 0
    this.questions = []
    this.updateQuestionsInput()
  }
  
  toggleType(event) {
    const selectedType = event.target.value
    
    if (selectedType === "development") {
      this.questionsSectionTarget.style.display = "block"
    } else {
      this.questionsSectionTarget.style.display = "none"
    }
  }
  
  addQuestion() {
    this.questionCount++
    const questionDiv = document.createElement("div")
    questionDiv.classList.add("border", "border-gray-200", "rounded-lg", "p-4", "space-y-3", "bg-gray-50")
    questionDiv.dataset.questionIndex = this.questionCount
    
    questionDiv.innerHTML = `
      <div class="flex items-center justify-between">
        <h3 class="text-sm font-medium text-gray-900">Question ${this.questionCount}</h3>
        <button type="button" class="text-red-600 hover:text-red-700" data-action="click->survey-builder#removeQuestion" data-question-index="${this.questionCount}">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
        </button>
      </div>
      
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Type de question</label>
        <select class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-admin-500" data-action="change->survey-builder#updateQuestion" data-question-index="${this.questionCount}" data-field="type">
          <option value="text">Texte court</option>
          <option value="textarea">Texte long</option>
          <option value="multiple_choice">Choix multiple</option>
          <option value="checkbox">Cases à cocher</option>
          <option value="rating">Note (1-5)</option>
          <option value="yes_no">Oui/Non</option>
        </select>
      </div>
      
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Question</label>
        <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-admin-500" placeholder="Votre question..." data-action="input->survey-builder#updateQuestion" data-question-index="${this.questionCount}" data-field="text">
      </div>
      
      <div class="options-container" style="display: none;" data-question-index="${this.questionCount}">
        <label class="block text-sm font-medium text-gray-700 mb-1">Options (une par ligne)</label>
        <textarea rows="3" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-admin-500" placeholder="Option 1&#10;Option 2&#10;Option 3" data-action="input->survey-builder#updateQuestion" data-question-index="${this.questionCount}" data-field="options"></textarea>
      </div>
      
      <div class="flex items-center">
        <label class="flex items-center cursor-pointer">
          <input type="checkbox" class="rounded border-gray-300 text-admin-600 focus:ring-admin-500 mr-2" data-action="change->survey-builder#updateQuestion" data-question-index="${this.questionCount}" data-field="required">
          <span class="text-sm font-medium text-gray-900">Question obligatoire</span>
        </label>
      </div>
    `
    
    this.questionsListTarget.appendChild(questionDiv)
    
    // Initialize question in array
    this.questions.push({
      id: this.questionCount,
      type: "text",
      text: "",
      options: [],
      required: false
    })
    
    this.updateQuestionsInput()
  }
  
  removeQuestion(event) {
    const questionIndex = parseInt(event.currentTarget.dataset.questionIndex)
    const questionDiv = this.questionsListTarget.querySelector(`[data-question-index="${questionIndex}"]`)
    
    if (questionDiv) {
      questionDiv.remove()
    }
    
    // Remove from questions array
    this.questions = this.questions.filter(q => q.id !== questionIndex)
    this.updateQuestionsInput()
  }
  
  updateQuestion(event) {
    const questionIndex = parseInt(event.currentTarget.dataset.questionIndex)
    const field = event.currentTarget.dataset.field
    const value = event.currentTarget.type === "checkbox" ? event.currentTarget.checked : event.currentTarget.value
    
    // Find the question
    const question = this.questions.find(q => q.id === questionIndex)
    
    if (question) {
      if (field === "options") {
        // Split options by newline
        question[field] = value.split("\n").filter(opt => opt.trim() !== "")
      } else {
        question[field] = value
      }
      
      // Show/hide options container based on question type
      if (field === "type") {
        const optionsContainer = this.questionsListTarget.querySelector(`.options-container[data-question-index="${questionIndex}"]`)
        if (optionsContainer) {
          if (value === "multiple_choice" || value === "checkbox") {
            optionsContainer.style.display = "block"
          } else {
            optionsContainer.style.display = "none"
          }
        }
      }
    }
    
    this.updateQuestionsInput()
  }
  
  updateQuestionsInput() {
    // Convert questions array to JSON and set it in the hidden field
    const questionsJson = JSON.stringify(this.questions)
    this.questionsInputTarget.value = questionsJson
  }
}
