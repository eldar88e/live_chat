if ("serviceWorker" in navigator) {
  window.addEventListener("load", function () {
    navigator.serviceWorker
      .register("/service-worker.js")
      .then(function () {
        // console.log('ServiceWorker is registered:', registration);
      })
      .catch(function (error) {
        console.log("Error registering ServiceWorker:", error);
      });
  });
}
