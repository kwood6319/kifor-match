import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["region", "city"]
  static values = { cities: Object }

  connect() {
    this.filter()
  }

  filter() {
    const region = this.regionTarget.value
    const cities = region ? (this.citiesValue[region] || []) : []
    const previous = this.cityTarget.value
    const promptOption = this.cityTarget.querySelector("option[value='']")
    const promptHTML = promptOption ? promptOption.outerHTML : ""

    this.cityTarget.innerHTML = promptHTML + cities.map(city => {
      const selected = city === previous ? " selected" : ""
      return `<option value="${city}"${selected}>${city}</option>`
    }).join("")
  }
}
