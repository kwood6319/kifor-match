import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "title", "submit"];
  connect() {
    this.element.addEventListener("show.bs.modal", (event) => {
      const url = event.relatedTarget?.dataset.actionUrl;
      const title = event.relatedTarget?.dataset.actionTitle;
      console.log(event.relatedTarget.dataset);
      console.log(event.relatedTarget.dataset.deleteTitle);
      this.titleTarget.textContent = title;
      // document.getElementById("deleteOfferForm").action = url
      this.formTarget.action = url;
    });
  }
}
