import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "submitButton"]
  static values = { firstOffer: Boolean }

  connect() {
    if (!this.firstOfferValue) {
      this.submitButtonTarget.disabled = !this.checkboxTarget.checked
    }
  }

  toggle() {
    this.submitButtonTarget.disabled = !this.checkboxTarget.checked
  }

  acknowledge() {
    this.checkboxTarget.checked = true
    this.submitButtonTarget.disabled = false
    this.checkboxTarget.focus()
  }
}
