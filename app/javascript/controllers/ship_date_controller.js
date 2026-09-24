import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ship-date"
//
// Keeps the "day" <select> in sync with the "month/year" <select> so:
//   1. A day that doesn't exist in the selected month (e.g. Feb 31)
//      can never be chosen.
//   2. If the selected month/year is the current month, days before
//      today are excluded (you can't promise to ship in the past).
// Re-renders the day options whenever the month/year changes,
// preserving the currently selected day when it's still valid.
export default class extends Controller {
  static targets = ["day", "monthYear"]

  connect() {
    this.syncDayOptions()
  }

  monthYearChanged() {
    this.syncDayOptions()
  }

  syncDayOptions() {
    const [year, month] = this.monthYearTarget.value.split("-").map(Number)
    if (!year || !month) return

    const daysInMonth = new Date(year, month, 0).getDate()
    const today = new Date()
    const isCurrentMonth = year === today.getFullYear() && month === today.getMonth() + 1
    const minDay = isCurrentMonth ? today.getDate() : 1

    const previouslySelected = Number(this.dayTarget.value)

    this.dayTarget.innerHTML = ""
    for (let day = minDay; day <= daysInMonth; day++) {
      const option = document.createElement("option")
      option.value = day
      option.textContent = day
      this.dayTarget.appendChild(option)
    }

    // Keep the previous day selected if it's still in range, otherwise
    // fall back to the closest valid day (clamped between minDay and
    // daysInMonth).
    if (previouslySelected >= minDay && previouslySelected <= daysInMonth) {
      this.dayTarget.value = previouslySelected
    } else if (previouslySelected < minDay) {
      this.dayTarget.value = minDay
    } else {
      this.dayTarget.value = daysInMonth
    }
  }
}
