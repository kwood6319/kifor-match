import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "submitButton"]

  acknowledge(event) {
    event.target.blur()
    this.checkboxTarget.checked = true
    this.submitButtonTarget.disabled = false
  }
}
