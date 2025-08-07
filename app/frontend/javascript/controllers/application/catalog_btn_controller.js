import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.catalogMenu = document.getElementById("catalogMenu");
    }

    toggle(event) {
        this.catalogMenu.classList.toggle("open");
    }
}