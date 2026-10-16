import { Controller } from "@hotwired/stimulus"

// Keeps the pickers from offering a range that ends before it starts.
export default class extends Controller {
  static targets = ["from", "to"]

  sync() {
    this.toTarget.min = this.fromTarget.value
    this.fromTarget.max = this.toTarget.value
  }
}
