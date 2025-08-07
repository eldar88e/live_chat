import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "messages"];

    connect() {
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
    }

    clear() {
        setTimeout(() => {
            this.inputTarget.value = ''
            setTimeout(() => {
                this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
            }, 100);
        })
    }
}
