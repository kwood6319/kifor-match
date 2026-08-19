import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() { console.log("Hello from the contact controller") }
  send(event) { 
    event.preventDefault();
    console.log("Intercepted!");
  }
}
