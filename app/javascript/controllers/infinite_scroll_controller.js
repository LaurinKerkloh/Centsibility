import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) this.load()
    })
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer.disconnect()
  }

  async load() {
    this.observer.disconnect()
    const response = await fetch(this.urlValue, { headers: { Accept: "text/vnd.turbo-stream.html" } })
    if (response.ok) Turbo.renderStreamMessage(await response.text())
  }
}
