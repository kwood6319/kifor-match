import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["region", "prefecture"]
  static values = { prefectures: Object }

  connect() {
    this.filter()
  }

  filter() {
    const region = this.regionTarget.value
    const prefectures = region ? (this.prefecturesValue[region] || []) : []
    const previous = this.prefectureTarget.value
    const promptOption = this.prefectureTarget.querySelector("option[value='']")
    const promptHTML = promptOption ? promptOption.outerHTML : ""

    this.prefectureTarget.innerHTML = promptHTML + prefectures.map(prefecture => {
      const selected = prefecture === previous ? " selected" : ""
      return `<option value="${prefecture}"${selected}>${prefecture}</option>`
    }).join("")
  }
}
