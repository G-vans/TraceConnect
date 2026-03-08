import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "messages", "input", "loading", "welcome"]

  connect() {
    if (localStorage.getItem("askSidebarCollapsed") === "true") {
      this.sidebarTarget.classList.add("collapsed")
    }
  }

  toggle() {
    this.sidebarTarget.classList.toggle("collapsed")
    localStorage.setItem(
      "askSidebarCollapsed",
      this.sidebarTarget.classList.contains("collapsed")
    )
  }

  submitQuery(event) {
    event.preventDefault()
    const query = this.inputTarget.value.trim()
    if (!query) return

    this.hideWelcome()
    this.appendMessage(query, "user")
    this.inputTarget.value = ""
    this.showLoading()

    const token = document.querySelector('meta[name="csrf-token"]').content
    fetch("/ask", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ query: query })
    })
    .then(response => response.text())
    .then(html => {
      this.hideLoading()
      Turbo.renderStreamMessage(html)
      this.scrollToBottom()
    })
    .catch(() => {
      this.hideLoading()
      this.appendMessage("Something went wrong. Please try again.", "system")
    })
  }

  clickSuggestion(event) {
    event.preventDefault()
    this.inputTarget.value = event.currentTarget.dataset.query
    this.submitQuery(event)
  }

  appendMessage(text, type) {
    const div = document.createElement("div")
    div.className = type === "user" ? "ask-msg-user" : "ask-msg-system"
    div.textContent = text
    this.messagesTarget.appendChild(div)
    this.scrollToBottom()
  }

  hideWelcome() {
    if (this.hasWelcomeTarget) {
      this.welcomeTarget.style.display = "none"
    }
  }

  showLoading() {
    this.loadingTarget.style.display = "flex"
    this.scrollToBottom()
  }

  hideLoading() {
    this.loadingTarget.style.display = "none"
  }

  scrollToBottom() {
    requestAnimationFrame(() => {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    })
  }
}
