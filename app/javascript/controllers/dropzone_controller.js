import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dropzone", "input", "loading"];
  static values = { url: String };

  connect() {
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
  }

  hideLoading() {
    this.dropzoneTarget.classList.remove("d-none");
    this.loadingTarget.classList.add("d-none");
  }
}
