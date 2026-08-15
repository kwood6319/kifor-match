import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categoryCheckbox", "subcategoryGroup", "subcategoryCheckbox"]

  connect() {
    this.sync()
  }

  toggle() {
    this.sync()
  }

  reset() {
    this.categoryCheckboxTargets.forEach((cb) => { cb.checked = false })
    this.subcategoryCheckboxTargets.forEach((cb) => { cb.checked = false })
    this.sync()
  }

  sync() {
    const checkedCategories = this.categoryCheckboxTargets
      .filter((cb) => cb.checked)
      .map((cb) => cb.dataset.category)

    this.subcategoryGroupTargets.forEach((group) => {
      const belongsToChecked = checkedCategories.includes(group.dataset.category)
      group.classList.toggle("d-none", !belongsToChecked)

      if (!belongsToChecked) {
        group.querySelectorAll('input[type="checkbox"]').forEach((cb) => { cb.checked = false })
      }
    })
  }
}
