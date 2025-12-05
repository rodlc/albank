import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  setFont(event) {
    const font = event.currentTarget.dataset.font
    this.contentTarget.style.fontFamily = font

    // Update active state
    this.element.querySelectorAll('[data-action]').forEach(el => {
      el.classList.remove('active', 'border-primary')
      el.classList.add('border-transparent')
    })
    event.currentTarget.classList.add('active', 'border-primary')
    event.currentTarget.classList.remove('border-transparent')
  }
}
