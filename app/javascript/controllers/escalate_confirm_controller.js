import { Controller } from "@hotwired/stimulus"

// Escalating flags the donation for an admin and feedback is locked once
// submitted, so ask before sending a form with Escalate ticked
export default class extends Controller {
  static targets = ["checkbox", "modal"]

  submit(event) {
    if (!this.checkboxTarget.checked || this.confirmed) return

    event.preventDefault()
    window.bootstrap.Modal.getOrCreateInstance(this.modalTarget).show()
  }

  confirm() {
    this.confirmed = true
    window.bootstrap.Modal.getOrCreateInstance(this.modalTarget).hide()
    this.element.requestSubmit()
  }
}
