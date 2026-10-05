import { Controller } from "@hotwired/stimulus"

// Interrupts form submission until the donor acknowledges the donation rules in a modal
export default class extends Controller {
  static targets = ["form", "modal", "checkbox", "confirmButton"]

  connect() {
    this.confirmed = false
  }

  intercept(event) {
    if (this.confirmed) return

    event.preventDefault()
    this.checkboxTarget.checked = false
    this.confirmButtonTarget.disabled = true
    window.bootstrap.Modal.getOrCreateInstance(this.modalTarget).show()
  }

  toggle() {
    this.confirmButtonTarget.disabled = !this.checkboxTarget.checked
  }

  confirm() {
    this.confirmed = true
    window.bootstrap.Modal.getOrCreateInstance(this.modalTarget).hide()
    this.formTarget.requestSubmit()
  }
}
