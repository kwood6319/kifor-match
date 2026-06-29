import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("show.bs.modal", (event) => {
      const url = event.relatedTarget?.dataset.deleteUrl
      document.getElementById("deleteOfferForm").action = url
    })
  }
}
