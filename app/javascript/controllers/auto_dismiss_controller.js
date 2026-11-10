import { Controller } from "@hotwired/stimulus"

// Closes a Bootstrap alert (with its usual fade) after `delay` ms, e.g. flash messages.
// The X still works.
// With a `form` target (a notification's dismiss form), it fades and submits that form, so the
// notification is marked read on the server rather than coming back on the next visit.
export default class extends Controller {
  static targets = ["form"]
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    if (this.hasFormTarget) {
      this.element.classList.remove("show") // Bootstrap's .fade transition; the server response removes it
      this.formTarget.requestSubmit()
    } else {
      window.bootstrap.Alert.getOrCreateInstance(this.element).close()
    }
  }
}
