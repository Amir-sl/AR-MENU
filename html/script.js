// Initial setup and listening to client messages
window.addEventListener('message', function(event) {
    let d = event.data;
    if (d.action === "openMenu") {
        document.body.style.display = "block";
        fetchPlayerList(null); // Default opening on the playlist
    } else if (d.action === "closeMenu") {
        document.body.style.display = "none";
    } else if (d.action === "updateData") {
        // Update name, ID and time
        document.getElementById('player-name').innerText = d.fullname;
        document.getElementById('player-id').innerText = d.id;
        document.getElementById('time').innerText = d.time;
        
        // Update job numbers in the journal
        document.getElementById('sheriffs').innerText = d.sheriffs;
        document.getElementById('medics').innerText = d.medics;
        document.getElementById('justice').innerText = d.justice;
        document.getElementById('pinkerton').innerText = d.pinkerton;
    } else if (d.action === "displayPlayers") {
        updatePlayerListUI(d.players);
    }
});

// Tabs Open Function - This is the same function that the error message is about.
function openTab(evt, tabName) {
    let i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tab-content");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("nav-btn");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].classList.remove("active");
    }
    document.getElementById(tabName).style.display = "block";
    if (evt) {
        evt.currentTarget.classList.add("active");
    }
}

//Get player list from server
function fetchPlayerList(evt) {
    fetch(`https://${GetParentResourceName()}/fetchPlayers`, {
        method: 'POST',
        body: JSON.stringify({})
    });
    openTab(evt, 'player-list-tab');
}

//Rendering the list of players in a table
function updatePlayerListUI(players) {
    const container = document.getElementById('player-list-container');
    container.innerHTML = '';
    players.forEach(p => {
        const div = document.createElement('div');
        div.className = 'player-row';
        div.innerHTML = `
            <div class="p-name">${p.name}</div>
            <div class="p-job">${p.job.toUpperCase()}</div>
            <div class="p-ping">${p.ping}ms</div>
        `;
        container.appendChild(div);
    });
}

// Exit button
document.getElementById('close-btn').onclick = () => {
    fetch(`https://${GetParentResourceName()}/exitMenu`, { method: 'POST' });
};