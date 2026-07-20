import { controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "submitButton"]

  acknowledge() {
    this.checkboxTarget.checked = true
    this.submitButtonTarget.disabled = false
  }
}
