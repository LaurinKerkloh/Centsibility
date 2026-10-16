import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = { url: String, retryDelay: { type: Number, default: 5000 } }

  connect() {
    this.observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) this.load()
    })
    this.observer.observe(this.element)
  }

  // A filter change swaps the list while a page may still be loading; its rows belong to the old list.
  disconnect() {
    this.observer.disconnect()
    this.request?.abort()
    clearTimeout(this.retry)
  }

  async load() {
    this.observer.disconnect()
    this.request = new AbortController()

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "text/vnd.turbo-stream.html" },
        signal: this.request.signal
      })
      if (!response.ok) throw new Error(`Loading ${this.urlValue} failed with ${response.status}`)

      Turbo.renderStreamMessage(await response.text())
    } catch (error) {
      if (error.name === "AbortError") return

      // Observing again right away would fire at once while the sentinel is in view, so wait before retrying.
      this.retry = setTimeout(() => this.observer.observe(this.element), this.retryDelayValue)
    }
  }
}
