import { Controller } from "@hotwired/stimulus";

// Keeps a fixed-position FAB floating with the page, but stops it from
// travelling down into the footer: once the footer scrolls into view the
// button is lifted by exactly the amount of footer that is visible.
export default class extends Controller {
  connect() {
    this.footer = document.querySelector("footer");
    if (!this.footer) return;

    this.update = this.update.bind(this);
    this.requestUpdate = this.requestUpdate.bind(this);

    window.addEventListener("scroll", this.requestUpdate, { passive: true });
    window.addEventListener("resize", this.requestUpdate, { passive: true });
    this.update();
  }

  disconnect() {
    window.removeEventListener("scroll", this.requestUpdate);
    window.removeEventListener("resize", this.requestUpdate);
    if (this.frame) cancelAnimationFrame(this.frame);
    this.element.style.removeProperty("--fab-lift");
  }

  requestUpdate() {
    if (this.frame) return;
    this.frame = requestAnimationFrame(() => {
      this.frame = null;
      this.update();
    });
  }

  update() {
    const footerTop = this.footer.getBoundingClientRect().top;
    const overlap = Math.max(0, window.innerHeight - footerTop);
    this.element.style.setProperty("--fab-lift", `${overlap}px`);
  }
}
