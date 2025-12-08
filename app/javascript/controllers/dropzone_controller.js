export default class {
  connect() {
    const dropZone = document.getElementById('dropZone');
    const fileInput = document.getElementById('file-input');
    const loadingState = document.getElementById('loading-state');

  // Click to upload
    fileInput.addEventListener('change', (e) => {
      if (e.target.files.length > 0) {
        handleFiles(e.target.files);
      }
    });

  // Drag & Drop
  dropZone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropZone.classList.add('dragover');
  });

  dropZone.addEventListener('dragleave', () => {
    dropZone.classList.remove('dragover');
  });

  dropZone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropZone.classList.remove('dragover');
    const files = e.dataTransfer.files;
    if (files.length > 0) {
      this.handleFiles(files);
    }
  });
}

  handleFiles(files) {
    const file = files[0];
    console.log("Fichier déposé :", file.name, file.size, file.type);

    // Show loading state
    const dropZone = document.getElementById('dropZone');
    const loadingState = document.getElementById('loading-state');

    // Simulate PDF import
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    const formData = new FormData();
    formData.append('file', file);

    fetch('<%= import_pdf_statements_path %>', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/html'
      },
      body: file // gestion FormData
    })
    .then(response => {
      if (response.redirected) {
        window.location.href = response.url;
      } else {
        return response.text().then(html => {
          document.body.innerHTML = html;
        });
      }
    })
    .catch(error => {
      console.error('Erreur import:', error);
      alert('Erreur lors de l\'importation. Veuillez réessayer.');
      dropZone.classList.remove('d-none');
      loadingState.classList.add('d-none');
    });
  }
}
