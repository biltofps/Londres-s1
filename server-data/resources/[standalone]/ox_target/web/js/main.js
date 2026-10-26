import { createOptions } from "./createOptions.js";

const optionsWrapper = document.getElementById("options-wrapper");
const body = document.body;
const targetingImage = document.getElementById("targetingImage");

// mesma escala do rsg-inventory: base 1920x1080
function applyScale() {
  const fit = Math.min(window.innerWidth / 1920, window.innerHeight / 1080);
  const s = Math.max(0.55, Math.min(2.5, fit));
  document.documentElement.style.setProperty("--ui-scale", s.toFixed(3));
}
window.addEventListener("resize", applyScale);
applyScale();

window.addEventListener("message", (event) => {
  optionsWrapper.innerHTML = "";

  switch (event.data.event) {
    case "visible": {
      body.style.visibility = event.data.state ? "visible" : "hidden";
      // Reset to untargeted state when not visible
      if (!event.data.state) {
        targetingImage.classList.remove("has-target");
      }
      return;
    }

    case "leftTarget": {
      targetingImage.classList.remove("has-target");
      return;
    }

    case "setTarget": {
      targetingImage.classList.add("has-target");

      if (event.data.options) {
        for (const type in event.data.options) {
          event.data.options[type].forEach((data, id) => {
            createOptions(type, data, id + 1);
          });
        }
      }

      if (event.data.zones) {
        for (let i = 0; i < event.data.zones.length; i++) {
          event.data.zones[i].forEach((data, id) => {
            createOptions("zones", data, id + 1, i + 1);
          });
        }
      }
    }
  }
});