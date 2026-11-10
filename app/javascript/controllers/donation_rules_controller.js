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
    if (this.confirmed) return // double click on Confirm

    this.confirmed = true
    this.confirmButtonTarget.disabled = true
    window.bootstrap.Modal.getOrCreateInstance(this.modalTarget).hide()
    // requestSubmit() has no submitter, so Turbo won't disable the Send button itself;
    // lock it while photos upload so a second click can't send the offer twice
    this.formTarget.querySelectorAll('[type="submit"]').forEach((button) => { button.disabled = true })
    this.formTarget.requestSubmit()
  }
}
