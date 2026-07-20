// app/javascript/controllers/form_submission_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categoryGroup"]

  allCategoryChanged(event) {
    if (event.target.checked) {
      // "All" checked — uncheck every specific category
      this.categoryCheckboxes().forEach((cb) => { if (cb.value !== "") cb.checked = false })
    }
  }

  categoryChanged(event) {
    if (event.target.checked) {
      // A specific category checked — uncheck "All"
      const allBox = this.categoryGroupTarget.querySelector('input[value=""]')
      if (allBox) allBox.checked = false
    } else {
      // If nothing is checked anymore, fall back to "All"
      const anyChecked = this.categoryCheckboxes().some((cb) => cb.checked)
      if (!anyChecked) {
        const allBox = this.categoryGroupTarget.querySelector('input[value=""]')
        if (allBox) allBox.checked = true
      }
    }
  }

  categoryCheckboxes() {
    return Array.from(this.categoryGroupTarget.querySelectorAll('input[type="checkbox"]'))
  }
}
