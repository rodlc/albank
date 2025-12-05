import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["source", "button", "feedback"]

  copy() {
    const text = this.sourceTarget.innerText

    navigator.clipboard.writeText(text).then(() => {
      this.showSuccess()
    }).catch(err => {
      console.error('Erreur lors de la copie:', err)
      alert('Impossible de copier le texte. Veuillez le sélectionner manuellement.')
    })
  }

  showSuccess() {
    // Show feedback
    this.feedbackTarget.classList.remove('d-none')

    // Update button
    const originalHTML = this.buttonTarget.innerHTML
    this.buttonTarget.innerHTML = '<i class="fas fa-check me-2"></i>Copié !'
    this.buttonTarget.classList.remove('btn-outline-primary')
    this.buttonTarget.classList.add('btn-success')

    // Reset after 3 seconds
    setTimeout(() => {
      this.feedbackTarget.classList.add('d-none')
      this.buttonTarget.innerHTML = originalHTML
      this.buttonTarget.classList.remove('btn-success')
      this.buttonTarget.classList.add('btn-outline-primary')
    }, 3000)
  }
}
