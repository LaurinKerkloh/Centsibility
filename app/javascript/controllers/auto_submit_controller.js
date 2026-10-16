import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    this.element.addEventListener("change", this.change)
    this.element.addEventListener("formdata", this.dropBlank)
  }

  disconnect() {
    this.element.removeEventListener("change", this.change)
    this.element.removeEventListener("formdata", this.dropBlank)
    clearTimeout(this.timer)
  }

  debounce() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.element.requestSubmit(), this.delayValue)
  }

  // Search fields submit through debounce while typing; their change on blur would only repeat that.
  change = (event) => {
    if (event.target.type === "search") return

    clearTimeout(this.timer)
    this.element.requestSubmit()
  }

  // Keeps the URL to the filters in use instead of a list of empty params.
  dropBlank = ({ formData }) => {
    for (const [name, value] of [...formData]) {
      if (value === "") formData.delete(name)
    }
  }
}
