import { Controller } from "@hotwired/stimulus"

// The donor must tick an acknowledgement before sending an offer: postage costs when
// shipping, respecting the charity's time when dropping off.
export default class extends Controller {
  static targets = ["checkbox", "submitButton", "shippingText", "dropOffText"]
  static values = { firstOffer: Boolean }

  connect() {
    if (!this.firstOfferValue) {
      this.submitButtonTarget.disabled = !this.checkboxTarget.checked
    }
  }

  toggle() {
    this.submitButtonTarget.disabled = !this.checkboxTarget.checked
  }

  acknowledge() {
    this.checkboxTarget.checked = true
    this.submitButtonTarget.disabled = false
    this.checkboxTarget.focus()
  }

  // Delivery method radio changed: show the matching wording and untick, since the
  // donor agreed to the other one
  methodChanged(event) {
    const dropOff = event.target.value === "drop_off"
    if (this.hasShippingTextTarget) this.shippingTextTarget.hidden = dropOff
    if (this.hasDropOffTextTarget) this.dropOffTextTarget.hidden = !dropOff
    this.checkboxTarget.checked = false
    this.submitButtonTarget.disabled = true
  }
}
