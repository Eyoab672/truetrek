function initCameraPage() {
  const video = document.getElementById("camera-video");
  const canvas = document.getElementById("camera-canvas");
  const photoPreview = document.getElementById("photo-preview");
  const previewImage = document.getElementById("preview-image");
  const takePhotoBtn = document.getElementById("take-photo");
  const cameraControls = document.getElementById("camera-controls");
  const actionButtons = document.getElementById("action-buttons");
  const looksGreatButton = document.getElementById("looks-great");
  const retakeButton = document.getElementById("retake-photo");
  const cameraPage = document.querySelector(".camera-new-page");

  if (!video || !canvas || !takePhotoBtn) return; // not on /camera

  // Get place_id if coming from a place page
  const placeId = cameraPage?.dataset?.placeId;

  let stream = null;
  let lastBlob = null;
  let lastLat = null;
  let lastLng = null;

  const csrfTokenEl = document.querySelector('meta[name="csrf-token"]');
  const csrfToken = csrfTokenEl ? csrfTokenEl.content : null;

  // Auto-start camera when page loads
  async function startCamera() {
    try {
      stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" },
        audio: false
      });
      video.srcObject = stream;
      video.style.display = "block";
    } catch (err) {
      console.error("Error accessing camera:", err);
      alert("Could not access camera. Please check permissions.");
    }
  }

  // Start camera on page load
  startCamera();

  // Take photo
  takePhotoBtn.addEventListener("click", () => {
    if (!stream) return;

    const width = video.videoWidth;
    const height = video.videoHeight;
    canvas.width = width;
    canvas.height = height;

    const ctx = canvas.getContext("2d");
    ctx.drawImage(video, 0, 0, width, height);

    canvas.toBlob((blob) => {
      if (!blob) return;
      lastBlob = blob;

      // Show preview and hide video
      const url = URL.createObjectURL(blob);
      previewImage.src = url;
      photoPreview.classList.remove("d-none");
      video.style.display = "none";
      cameraControls.classList.add("d-none");
      actionButtons.classList.remove("d-none");

      // Stop camera stream
      if (stream) {
        stream.getTracks().forEach(track => track.stop());
        stream = null;
      }

      // Get geolocation
      if ("geolocation" in navigator) {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            lastLat = position.coords.latitude;
            lastLng = position.coords.longitude;
          },
          (error) => console.warn("Geolocation error:", error),
          { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
        );
      }
    }, "image/png");
  });

  // Retake photo
  if (retakeButton) {
    retakeButton.addEventListener("click", () => {
      photoPreview.classList.add("d-none");
      actionButtons.classList.add("d-none");
      cameraControls.classList.remove("d-none");
      lastBlob = null;
      lastLat = null;
      lastLng = null;
      startCamera();
    });
  }

  async function sendCapture() {
    if (!lastBlob) {
      alert("Please take a photo first.");
      return;
    }

    const formData = new FormData();
    formData.append("image", lastBlob, "capture.png");
    if (lastLat != null) formData.append("latitude", lastLat);
    if (lastLng != null) formData.append("longitude", lastLng);
    if (placeId) formData.append("place_id", placeId);

    console.log("Uploading photo...");
    console.log("Blob size:", lastBlob.size);
    console.log("CSRF token:", csrfToken);

    try {
      const response = await fetch("/camera", {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken || "",
          "Accept": "application/json"
        },
        body: formData
      });

      console.log("Response status:", response.status);

      if (!response.ok) {
        const errorText = await response.text();
        console.error("Upload failed:", response.status, errorText);
        let errorMessage = `Upload failed (${response.status})`;
        try {
          const errorData = JSON.parse(errorText);
          errorMessage = errorData.error || errorMessage;
        } catch (e) {
          errorMessage = errorText || errorMessage;
        }
        alert(`Error uploading photo: ${errorMessage}`);
        return;
      }

      const data = await response.json();
      console.log("Response data:", data);
      if (data.redirect_to) {
        window.location.href = data.redirect_to;
      }
    } catch (err) {
      console.error("Error sending capture:", err);
      alert(`Network error while sending photo: ${err.message}`);
    }
  }

  if (looksGreatButton) {
    looksGreatButton.addEventListener("click", sendCapture);
  }
}

document.addEventListener("turbo:load", initCameraPage);
document.addEventListener("DOMContentLoaded", initCameraPage);
