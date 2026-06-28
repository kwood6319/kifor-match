import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("show.bs.modal", (event) => {
      const url = event.relatedTarget?.dataset.rejectUrl
      console.log("relatedTarget:", event.relatedTarget)
      console.log("rejectUrl:", url)
      document.getElementById("rejectOfferForm").action = url
      document.getElementById("rejection_reason").value = ""
    })

    document.getElementById("rejectOfferForm").addEventListener("submit", (event) => {
  console.log("submit fired")
  console.log("action:", event.target.action)
  console.log("method:", event.target.method)
})
  }
}
