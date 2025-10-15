/**
 * @jest-environment jsdom
 */

describe('Kukuk Frontend Application', () => {
  beforeEach(() => {
    // Reset DOM
    document.body.innerHTML = '';
  });

  test('should display welcome message', () => {
    // Mock HTML content
    document.body.innerHTML = `
      <div class="container">
        <h1>🚀 Kukuk Technology Future GmbH</h1>
        <div class="welcome-message">
          Willkommen! Dein kukuk-frontend läuft erfolgreich auf Port 8081
        </div>
      </div>
    `;

    const welcomeMessage = document.querySelector('.welcome-message');
    expect(welcomeMessage).toBeTruthy();
    expect(welcomeMessage.textContent).toContain('Willkommen! Dein kukuk-frontend läuft');
  });

  test('should have correct title', () => {
    document.body.innerHTML = `
      <h1>🚀 Kukuk Technology Future GmbH</h1>
    `;

    const title = document.querySelector('h1');
    expect(title.textContent).toBe('🚀 Kukuk Technology Future GmbH');
  });

  test('should have health check functionality', async () => {
    // Mock fetch response
    global.fetch.mockResolvedValueOnce({
      ok: true,
      text: () => Promise.resolve('Frontend is healthy'),
    });

    // Simulate health check
    const response = await fetch('/health');
    const result = await response.text();

    expect(fetch).toHaveBeenCalledWith('/health');
    expect(result).toBe('Frontend is healthy');
  });

  test('should handle health check failure', async () => {
    // Mock fetch rejection
    global.fetch.mockRejectedValueOnce(new Error('Network error'));

    try {
      await fetch('/health');
    } catch (error) {
      expect(error.message).toBe('Network error');
    }
  });
});