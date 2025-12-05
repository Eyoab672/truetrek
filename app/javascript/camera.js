function initCameraPage() {
  const startButton = document.getElementById("start-camera");
  const takePhotoButton = document.getElementById("take-photo");
  const stopButton = document.getElementById("stop-camera");
  const video = document.getElementById("camera-video");
  const canvas = document.getElementById("camera-canvas");
  const photo = document.getElementById("camera-photo");
  const newPlaceButton = document.getElementById("use-for-new-place");
  const existingPlaceButton = document.getElementById("use-for-existing-place");

  if (!startButton || !video || !canvas || !photo) return; // not on /camera

  let stream = null;
  let lastBlob = null;
  let lastLat = null;
  let lastLng = null;

  const csrfTokenEl = document.querySelector('meta[name="csrf-token"]');
  const csrfToken = csrfTokenEl ? csrfTokenEl.content : null;

  async function startCamera() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      alert("Camera API not supported in this browser.");
      return;
    }

    try {
      stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" },
        audio: false
      });

      video.srcObject = stream;
      takePhotoButton.disabled = false;
      stopButton.disabled = false;
      startButton.disabled = true;
    } catch (err) {
      console.error("Error accessing camera:", err);
      alert("Could not access camera. Make sure you're on HTTPS and camera permissions are granted.");
    }
  }

  startButton.addEventListener("click", startCamera);

  // Take photo: draw to canvas -> create Blob -> get geolocation
  takePhotoButton.addEventListener("click", () => {
    if (!stream) return;

    const videoTrack = stream.getVideoTracks()[0];
    const settings = videoTrack.getSettings();

    const width = settings.width || video.videoWidth;
    const height = settings.height || video.videoHeight;

    canvas.width = width;
    canvas.height = height;

    const ctx = canvas.getContext("2d");
    ctx.drawImage(video, 0, 0, width, height);

    canvas.toBlob(
      (blob) => {
        if (!blob) return;
        lastBlob = blob;

        // Show preview
        const url = URL.createObjectURL(blob);
        photo.src = url;

        // Get geolocation
        if ("geolocation" in navigator) {
          navigator.geolocation.getCurrentPosition(
            (position) => {
              lastLat = position.coords.latitude;
              lastLng = position.coords.longitude;
              newPlaceButton.disabled = false;
              existingPlaceButton.disabled = false;
            },
            (error) => {
              console.warn("Geolocation error:", error);
              // Allow user to proceed, but we won't auto-select city
              newPlaceButton.disabled = false;
              existingPlaceButton.disabled = false;
            },
            { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
          );
        } else {
          newPlaceButton.disabled = false;
          existingPlaceButton.disabled = false;
        }
      },
      "image/png"
    );
  });

  // Stop camera
  stopButton.addEventListener("click", () => {
    if (!stream) return;
    stream.getTracks().forEach((track) => track.stop());
    stream = null;

    video.srcObject = null;
    takePhotoButton.disabled = true;
    stopButton.disabled = true;
    startButton.disabled = false;
  });

  async function sendCapture(nextAction) {
    if (!lastBlob) {
      alert("Please take a photo first.");
      return;
    }

    const formData = new FormData();
    formData.append("image", lastBlob, "capture.png");
    if (lastLat != null) formData.append("latitude", lastLat);
    if (lastLng != null) formData.append("longitude", lastLng);
    formData.append("next_action", nextAction);

    try {
      const response = await fetch("/camera", {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken || "",
          "Accept": "application/json"
        },
        body: formData
      });

      if (!response.ok) {
        console.error("Upload failed:", response);
        alert("Error uploading photo.");
        return;
      }

      const data = await response.json();
      if (data.redirect_to) {
        window.location.href = data.redirect_to;
      }
    } catch (err) {
      console.error("Error sending capture:", err);
      alert("Network error while sending photo.");
    }
  }

  newPlaceButton.addEventListener("click", () => sendCapture("new_place"));
  existingPlaceButton.addEventListener("click", () => sendCapture("existing_place"));
}

document.addEventListener("turbo:load", initCameraPage);
document.addEventListener("DOMContentLoaded", initCameraPage);
