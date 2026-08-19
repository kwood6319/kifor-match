import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    redirectUrl: String,
    successMessage: String,
    errorMessage: String,
    networkErrorMessage: String
  };

  async send(event) {
    event.preventDefault();

    // Grab all the form data automatically (including the hidden access key)
    const formData = new FormData(this.element);

    let response;

    // Only the network call belongs in the try: anything after a successful
    // response would otherwise land in the catch and show a network error.
    try {
      response = await fetch(this.element.action, {
        method: "POST",
        body: formData,
        headers: {
          "Accept": "application/json"
        }
      });
    } catch (error) {
      alert(this.networkErrorMessageValue);
      return;
    }

    if (!response.ok) {
      alert(this.errorMessageValue);
      return;
    }

    alert(this.successMessageValue);
    this.element.reset();
    window.location.href = this.redirectUrlValue;
  }
}
