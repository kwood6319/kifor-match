import { Controller } from "@hotwired/stimulus"

// Limits the prefecture select to the chosen region.
// prefecturesValue maps each region to [label, value] pairs so labels stay translated.
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

    this.prefectureTarget.replaceChildren(...[
      ...(promptOption ? [promptOption] : []),
      ...prefectures.map(([label, value]) => new Option(label, value, false, value === previous))
    ])
    this.prefectureTarget.disabled = prefectures.length === 0
  }
}
