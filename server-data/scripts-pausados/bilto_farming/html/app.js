const RING_LENGTH = 326.73;

const $ = (id) => document.getElementById(id);
const plantPanel = $("plant");
const stamp = document.querySelector(".stamp");
let lastImage = null;

function clamp(value) {
    const num = Number(value);
    if (Number.isNaN(num)) return 0;
    return Math.max(0, Math.min(100, num));
}

function formatTime(minutes) {
    const m = Math.max(0, Math.floor(Number(minutes) || 0));
    if (m >= 60) {
        const h = Math.floor(m / 60);
        const rest = m % 60;
        return { value: rest > 0 ? `${h}h${String(rest).padStart(2, "0")}` : `${h}h`, unit: "restante" };
    }
    return { value: String(m), unit: m === 1 ? "minuto" : "minutos" };
}

function getPhase(p) {
    if (p.ready && p.watered) return { key: "ready", label: "Pronta", hint: "Pronta para colher!" };
    if (p.ready) return { key: "needwater", label: "Necessita regar", hint: "Regue a planta para poder colher." };
    if (p.waitingWater) return { key: "thirsty", label: "Necessita regar", hint: "O crescimento parou até a planta ser regada." };
    const pending = [];
    if (!p.fert) pending.push("adube");
    if (!p.trimmed) pending.push("pode");
    if (pending.length) {
        return { key: "growing", label: "Crescendo", hint: `Dica: ${pending.join(" e ")} para render mais.` };
    }
    return { key: "growing", label: "Crescendo", hint: "Tudo em dia. É só esperar." };
}

function setTile(id, done, doneText, pendingText) {
    const tile = $(id);
    tile.classList.toggle("done", done);
    tile.classList.toggle("pending", !done);
    tile.querySelector("b").textContent = done ? doneText : pendingText;
}

function render(p) {
    if (!p) return;

    $("pName").textContent = p.label || "Planta";
    $("pOwner").textContent = p.owner ? "Sua plantação" : "Plantação de outro";
    $("pLevel").textContent = p.level || 0;
    $("pLevelBar").style.width = `${clamp(p.levelPct)}%`;

    if (p.image !== lastImage) {
        lastImage = p.image;
        stamp.classList.toggle("no-img", !p.image);
        if (p.image) $("pImg").src = p.image;
    }

    const phase = getPhase(p);
    plantPanel.dataset.phase = phase.key;
    $("pPhase").textContent = phase.label;
    $("pHint").textContent = phase.hint;

    const pct = clamp(p.growthPct);
    $("pPct").textContent = pct;
    $("pRing").style.strokeDashoffset = `${RING_LENGTH * (1 - pct / 100)}`;

    if (p.ready) {
        $("pTime").textContent = "✓";
        $("pUnit").textContent = "pronta";
    } else {
        const t = formatTime(p.timer);
        $("pTime").textContent = t.value;
        $("pUnit").textContent = t.unit;
    }

    setTile("tWater", p.watered, "Regada", "Seca");
    setTile("tFert", p.fert, "Adubada", "Pendente");
    setTile("tTrim", p.trimmed, "Podada", "Pendente");

    const maxHealth = Number(p.maxHealth) || 100;
    const healthPct = clamp((Number(p.health) / maxHealth) * 100);
    const healthTile = $("tHealth");
    healthTile.classList.toggle("done", healthPct > 50);
    healthTile.classList.toggle("low", healthPct <= 50);
    healthTile.querySelector("b").textContent = `${Math.round(healthPct)}%`;
    $("tHealthBar").style.width = `${healthPct}%`;
}

$("pImg").addEventListener("error", () => stamp.classList.add("no-img"));

window.addEventListener("message", (event) => {
    const data = event.data || {};
    switch (data.action) {
        case "showPlant":
            render(data.plant);
            plantPanel.classList.remove("hidden");
            break;
        case "updatePlant":
            render(data.plant);
            break;
        case "hidePlant":
            plantPanel.classList.add("hidden");
            break;
        case "showWagon":
            $("wValue").textContent = data.waterText || "--";
            $("wBar").style.width = `${clamp(data.waterPct)}%`;
            $("wagon").classList.remove("hidden");
            break;
        case "hideWagon":
            $("wagon").classList.add("hidden");
            break;
        case "zoneTool":
            $("ztName").textContent = data.name || "Nova zona";
            $("ztPoints").textContent = data.points || 0;
            $("ztHeight").textContent = Number(data.height || 0).toFixed(1);
            $("zonetool").classList.remove("hidden");
            break;
        case "zoneToolHide":
            $("zonetool").classList.add("hidden");
            break;
        case "copy": {
            const area = document.createElement("textarea");
            area.value = data.text || "";
            document.body.appendChild(area);
            area.select();
            try {
                document.execCommand("copy");
            } catch (e) {}
            area.remove();
            break;
        }
    }
});
