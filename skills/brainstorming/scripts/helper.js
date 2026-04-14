(function() {
  const WS_URL = 'ws://' + window.location.host;
  let ws = null;
  let eventQueue = [];

  function connect() {
    ws = new WebSocket(WS_URL);

    ws.onopen = () => {
      eventQueue.forEach(e => ws.send(JSON.stringify(e)));
      eventQueue = [];
    };

    ws.onmessage = (msg) => {
      const data = JSON.parse(msg.data);
      if (data.type === 'reload') {
        window.location.reload();
      }
    };

    ws.onclose = () => {
      setTimeout(connect, 1000);
    };
  }

  function sendEvent(event) {
    event.timestamp = Date.now();
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(event));
    } else {
      eventQueue.push(event);
    }
  }

  // Send "done" event when user clicks Continue
  function sendDone() {
    const selection = window.selectedChoice;
    const container = document.querySelector('.options, .cards');
    const selected = container ? container.querySelectorAll('.selected') : [];
    
    sendEvent({
      type: 'done',
      choice: selection,
      selections: Array.from(selected).map(el => el.dataset.choice),
      text: selected.length === 1 
        ? selected[0].querySelector('h3, .content h3, .card-body h3')?.textContent?.trim() || selection
        : `${selected.length} items selected`
    });
  }

  // Update indicator text and button visibility
  function updateIndicator() {
    const indicator = document.getElementById('indicator-text');
    const continueBtn = document.getElementById('continue-btn');
    if (!indicator || !continueBtn) return;

    const container = document.querySelector('.options, .cards');
    const selected = container ? container.querySelectorAll('.selected') : [];

    if (selected.length === 0) {
      indicator.textContent = 'Click an option above';
      continueBtn.classList.remove('visible');
    } else if (selected.length === 1) {
      const label = selected[0].querySelector('h3, .content h3, .card-body h3')?.textContent?.trim() || selected[0].dataset.choice;
      indicator.innerHTML = '<span class="selected-text">' + label + '</span> selected';
      continueBtn.classList.add('visible');
    } else {
      indicator.innerHTML = '<span class="selected-text">' + selected.length + '</span> selected';
      continueBtn.classList.add('visible');
    }
  }

  // Wire up Continue button
  document.addEventListener('DOMContentLoaded', () => {
    const continueBtn = document.getElementById('continue-btn');
    if (continueBtn) {
      continueBtn.addEventListener('click', (e) => {
        e.preventDefault();
        sendDone();
        continueBtn.disabled = true;
        continueBtn.textContent = 'Sent!';
        const indicator = document.getElementById('indicator-text');
        if (indicator) indicator.textContent = 'Returning to terminal...';
      });
    }
  });

  // Capture clicks on choice elements
  document.addEventListener('click', (e) => {
    const target = e.target.closest('[data-choice]');
    if (!target) return;

    sendEvent({
      type: 'click',
      text: target.textContent.trim(),
      choice: target.dataset.choice,
      id: target.id || null
    });

    // Update indicator bar (defer so toggleSelect runs first)
    setTimeout(updateIndicator, 0);
  });

  // Frame UI: selection tracking
  window.selectedChoice = null;

  window.toggleSelect = function(el) {
    const container = el.closest('.options') || el.closest('.cards');
    const multi = container && container.dataset.multiselect !== undefined;
    if (container && !multi) {
      container.querySelectorAll('.option, .card').forEach(o => o.classList.remove('selected'));
    }
    if (multi) {
      el.classList.toggle('selected');
    } else {
      el.classList.add('selected');
    }
    window.selectedChoice = el.dataset.choice;
  };

  // Expose API for explicit use
  window.brainstorm = {
    send: sendEvent,
    choice: (value, metadata = {}) => sendEvent({ type: 'choice', value, ...metadata }),
    done: sendDone
  };

  connect();
})();
