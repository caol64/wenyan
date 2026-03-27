export function getWenyanElement(): HTMLElement {
    const wenyanElement = document.getElementById("wenyan");
    if (!wenyanElement) {
        throw new Error("Wenyan element not found");
    }
    const clonedWenyan = wenyanElement.cloneNode(true) as HTMLElement;
    clonedWenyan.querySelectorAll("img").forEach(async (element) => {
        const dataSrc = element.getAttribute("data-src");
        if (dataSrc) {
            element.src = dataSrc;
        }
    });
    return clonedWenyan;
}
