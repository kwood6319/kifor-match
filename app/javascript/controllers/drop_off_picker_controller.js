import { Controller } from "@hotwired/stimulus"

// Planned drop-off: a date from the browser's picker, then a time from 30-minute slots within
// that day's hours. The picker can't grey out weekdays, so a closed day shows a warning and
// holds Save. The server checks the same rules.
//
// windowsValue: [{ day: 0-6 (Sunday first, like Date#getDay), opens: "09:00", closes: "17:00" }]
// With no hours on record, defaultHoursValue (["07:00", "21:00"]) applies to every day.
export default class extends Controller {
  static targets = ["date", "time", "warning", "submit"]
  static values = {
    windows: Array,
    defaultHours: Array,
    prompt: String,
    fullDayNames: Array,
    closedMessage: String
  }

  connect() {
    // The server already rendered the slots for a saved date; just check it
    this.showWarning(this.closedWarning(this.chosenDate()))
  }

  dateChanged() {
    const date = this.chosenDate()
    this.rebuildTimes(date ? this.hoursFor(date) : null)
    this.showWarning(this.closedWarning(date))
  }

  // { opens, closes } for that day, or null when the charity is closed
  hoursFor(date) {
    if (this.windowsValue.length === 0) {
      const [opens, closes] = this.defaultHoursValue
      return { opens, closes }
    }
    return this.windowsValue.find((w) => w.day === date.getDay()) || null
  }

  closedWarning(date) {
    if (!date || this.hoursFor(date)) return null
    return this.closedMessageValue.replace("%{day}", this.fullDayNamesValue[date.getDay()])
  }

  // Replace the time options with 30-minute slots, keeping the chosen time if it's still offered
  rebuildTimes(hours) {
    const previous = this.timeTarget.value
    const options = [new Option(this.promptValue, "")]
    if (hours) {
      const toMinutes = (time) => { const [h, m] = time.split(":").map(Number); return h * 60 + m }
      const first = Math.ceil(toMinutes(hours.opens) / 30) * 30 // e.g. opens 9:15 -> first slot 9:30
      for (let minutes = first; minutes < toMinutes(hours.closes); minutes += 30) {
        const value = `${String(Math.floor(minutes / 60)).padStart(2, "0")}:${String(minutes % 60).padStart(2, "0")}`
        options.push(new Option(value.replace(/^0/, ""), value, false, value === previous))
      }
    }
    this.timeTarget.replaceChildren(...options)
    this.timeTarget.disabled = !hours
  }

  showWarning(message) {
    this.warningTarget.textContent = message || ""
    this.warningTarget.hidden = !message
    this.submitTarget.disabled = Boolean(message)
  }

  // "2026-10-13" as a local date (new Date("2026-10-13") would be UTC and can shift the day)
  chosenDate() {
    const [year, month, day] = this.dateTarget.value.split("-").map(Number)
    return year && month && day ? new Date(year, month - 1, day) : null
  }
}
