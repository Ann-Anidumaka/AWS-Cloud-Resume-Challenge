const counter = document.querySelector(".counter-number");
async function updateCounter() {
    let response = await fetch("Your-LambdaFunction-URL");
    let data = await response.json();
    counter.innerHTML = ` This page has ${data} Views!`;
}

updateCounter();