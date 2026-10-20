import { Controller } from "@hotwired/stimulus"

// Subcategories take their parent's colour, so the colour only matters without a parent.
export default class extends Controller {
  static targets = ["parent", "color"]

  connect() {
    this.toggle()
  }

  toggle() {
    this.colorTarget.hidden = this.parentTarget.value !== ""
  }
}
