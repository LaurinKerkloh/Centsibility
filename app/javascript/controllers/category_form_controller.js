import { Controller } from "@hotwired/stimulus"

// Subcategories take their parent's colour, so the colour only matters without a parent.
export default class extends Controller {
  static targets = ["parent", "color"]

  connect() {
    this.toggle()
  }

  toggle() {
    const hasParent = this.parentTarget.value !== ""
    this.colorTarget.hidden = hasParent
    this.colorTarget.disabled = hasParent
  }
}
