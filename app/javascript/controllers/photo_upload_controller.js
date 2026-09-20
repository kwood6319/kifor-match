import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="photo-upload"
//
// Wraps a hidden <input type="file" multiple> with a clickable/droppable
// zone and renders thumbnail previews with per-photo remove buttons.
// Keeps the input's FileList in sync via the DataTransfer API so Rails
// still receives the correct files on submit.
export default class extends Controller {
  static targets = ["input", "dropzone", "previewList", "previewTemplate"]

  connect() {
    this.files = []
  }

  // Opens the native file picker when the dropzone is clicked
  browse() {
    this.inputTarget.click()
  }

  // Fired when files are chosen via the native picker
  inputChanged() {
    this.addFiles(this.inputTarget.files)
  }

  dragOver(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.add("is-dragover")
  }

  dragLeave(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.remove("is-dragover")
  }

  drop(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.remove("is-dragover")
    this.addFiles(event.dataTransfer.files)
  }

  addFiles(fileList) {
    Array.from(fileList).forEach((file) => {
      if (file.type.startsWith("image/")) {
        this.files.push(file)
      }
    })
    this.syncInput()
    this.renderPreviews()
  }

  removePhoto(event) {
    const index = Number(event.params.index)
    this.files.splice(index, 1)
    this.syncInput()
    this.renderPreviews()
  }

  // Rebuilds the input's FileList from this.files so the form submits
  // exactly the files currently shown in the preview list.
  syncInput() {
    const dataTransfer = new DataTransfer()
    this.files.forEach((file) => dataTransfer.items.add(file))
    this.inputTarget.files = dataTransfer.files
  }

  renderPreviews() {
    this.previewListTarget.innerHTML = ""

    this.files.forEach((file, index) => {
      const reader = new FileReader()
      reader.onload = (event) => {
        const thumb = document.createElement("div")
        thumb.className = "km--photo-upload-thumb"
        thumb.innerHTML = `
          <img src="${event.target.result}" alt="">
          <button type="button" class="km--photo-upload-remove" aria-label="Remove photo"
            data-action="click->photo-upload#removePhoto" data-photo-upload-index-param="${index}">
            <i class="fa-solid fa-xmark"></i>
          </button>
        `
        this.previewListTarget.appendChild(thumb)
      }
      reader.readAsDataURL(file)
    })
  }
}
