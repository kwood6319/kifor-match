import { Controller } from "@hotwired/stimulus"

// Shows the content target only while the toggle checkbox is ticked,
// e.g. drop-off hours only once "Accept drop-offs" is on.
export default class extends Controller {
  static targets = ["toggle", "content"]

  connect() {
    this.update()
  }

  update() {
    this.contentTarget.hidden = !this.toggleTarget.checked
  }
}
