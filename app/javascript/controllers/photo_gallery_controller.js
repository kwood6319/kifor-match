import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mainImage", "thumb"]

  select(event) {
    const fullSrc = event.params.fullSrc
    if (fullSrc && this.hasMainImageTarget) {
      this.mainImageTarget.src = fullSrc
    }

    this.thumbTargets.forEach((thumb) => {
      thumb.classList.toggle("photo-gallery-thumb-active", thumb === event.currentTarget)
    })
  }
}
