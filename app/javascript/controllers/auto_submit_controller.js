import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    this.submitted = this.serialize()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  debounce() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.submit(), this.delayValue)
  }

  // A debounced field fires change again on blur, which would only repeat the last submit.
  submit() {
    clearTimeout(this.timer)
    const data = this.serialize()
    if (data === this.submitted) return

    this.submitted = data
    this.element.requestSubmit()
  }

  // Keeps the URL to the filters in use instead of a list of empty params.
  dropBlank({ formData }) {
    for (const [name, value] of [...formData]) {
      if (value === "") formData.delete(name)
    }
  }

  serialize() {
    return new URLSearchParams(new FormData(this.element)).toString()
  }
}
