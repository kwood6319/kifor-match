import { Controller } from "@hotwired/stimulus"

// Opens a Bootstrap modal as soon as it's on the page, e.g. settings errors after a failed save.
export default class extends Controller {
  connect() {
    window.bootstrap.Modal.getOrCreateInstance(this.element).show()
  }

  disconnect() {
    window.bootstrap.Modal.getInstance(this.element)?.dispose()
  }
}
