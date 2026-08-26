import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "title", "submit", "method"];
  connect() {
    this.element.addEventListener("show.bs.modal", (event) => {
      const { actionUrl, actionTitle, actionMethod, actionLabel } =
        event.relatedTarget?.dataset ?? {};

      this.titleTarget.textContent = actionTitle;
      this.formTarget.action = actionUrl;
      this.methodTarget.value = actionMethod || "delete";
      this.submitTarget.value = actionLabel || this.submitTarget.dataset.defaultLabel;
    });
  }
}
