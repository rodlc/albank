import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dropzone", "input", "loading", "loadingTitle", "loadingText"];
  static values = { url: String };

  // Messages à alterner
  loadingMessages = [
    { title: "Analyse sécurisée en cours...", text: "Traitement 100% anonymisé sur serveurs français 🥖" },
    { title: "Lecture de votre relevé...", text: "Comparaison avec les archives de la Banque de France 🗂️" },
    { title: "Détection des anomalies...", text: "Interrogatoire de vos abonnements oubliés 🔮" },
    { title: "Presque terminé...", text: "Traque des euros qui s'échappent discrètement 💸" }
  ];

  connect() {
    this.currentMessageIndex = 0;
    this.messageInterval = null;

    this.inputTarget.addEventListener("change", (e) => {
      if (e.target.files.length > 0) {
        this.handleFiles(e.target.files);
      }
    });

    this.dropzoneTarget.addEventListener("dragover", (e) => {
      e.preventDefault();
      this.dropzoneTarget.classList.add("dragover");
    });

    this.dropzoneTarget.addEventListener("dragleave", () => {
      this.dropzoneTarget.classList.remove("dragover");
    });

    this.dropzoneTarget.addEventListener("drop", (e) => {
      e.preventDefault();
      this.dropzoneTarget.classList.remove("dragover");
      if (e.dataTransfer.files.length > 0) {
        this.handleFiles(e.dataTransfer.files);
      }
    });
  }

  disconnect() {
    this.stopMessageRotation();
  }

  handleFiles(files) {
    const file = files[0];

    if (file.type !== "application/pdf") {
      alert("Veuillez importer un fichier PDF.");
      return;
    }

    this.showLoading();

    const formData = new FormData();
    formData.append("file", file);

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        Accept: "text/html",
      },
      body: formData,
    })
      .then((response) => {
        if (response.redirected) {
          window.location.href = response.url;
        } else {
          return response.text().then((html) => {
            document.body.innerHTML = html;
          });
        }
      })
      .catch((error) => {
        console.error("Erreur import:", error);
        alert("Erreur lors de l'importation. Veuillez réessayer.");
        this.hideLoading();
      });
  }

  showLoading() {
    this.dropzoneTarget.classList.add("d-none");
    this.loadingTarget.classList.remove("d-none");
    this.startMessageRotation();
  }

  hideLoading() {
    this.dropzoneTarget.classList.remove("d-none");
    this.loadingTarget.classList.add("d-none");
    this.stopMessageRotation();
  }

  startMessageRotation() {
    this.currentMessageIndex = 0;
    this.updateMessage();

    this.messageInterval = setInterval(() => {
      this.currentMessageIndex = (this.currentMessageIndex + 1) % this.loadingMessages.length;
      this.updateMessage();
    }, 4000); // 5 secondes
  }

  stopMessageRotation() {
    if (this.messageInterval) {
      clearInterval(this.messageInterval);
      this.messageInterval = null;
    }
  }

  updateMessage() {
    const message = this.loadingMessages[this.currentMessageIndex];

    if (this.hasLoadingTitleTarget) {
      this.loadingTitleTarget.textContent = message.title;
    }
    if (this.hasLoadingTextTarget) {
      this.loadingTextTarget.textContent = message.text;
    }
  }
}
