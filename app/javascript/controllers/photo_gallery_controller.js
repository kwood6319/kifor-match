import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mainImage"]

  select(event) {
    const fullSrc = event.params.fullSrc
    if (fullSrc && this.hasMainImageTarget) {
      this.mainImageTarget.src = fullSrc
    }
  }
}
