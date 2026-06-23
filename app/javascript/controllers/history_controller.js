import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  back(event) {
    event.preventDefault()
    window.history.back()
  }
}
