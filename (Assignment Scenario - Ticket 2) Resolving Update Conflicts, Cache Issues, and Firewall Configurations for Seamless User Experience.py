import os
import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys

def clear_chrome_browsing_data(chromedriver_path):
    try:
        # Set up Chrome options
        chrome_options = webdriver.ChromeOptions()
        chrome_options.add_argument("--start-maximized")  # Open Chrome in maximized mode
        chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])  # Disable automation message

        # Initialize Chrome WebDriver
        service = Service(chromedriver_path)
        driver = webdriver.Chrome(service=service, options=chrome_options)

        # Open Chrome's settings page
        driver.get("chrome://settings/clearBrowserData")
        time.sleep(3)  # Wait for the settings page to load

        # Use JavaScript to set the time range to "All time"
        driver.execute_script("document.querySelector('settings-ui').shadowRoot.querySelector('settings-main').shadowRoot.querySelector('settings-basic-page').shadowRoot.querySelector('settings-section > settings-privacy-page').shadowRoot.querySelector('settings-clear-browsing-data-dialog').shadowRoot.querySelector('#clearFromBasic').value = 4;")

        # Uncheck "Passwords" and "Other sign-in data"
        driver.execute_script("""
            const checkboxes = document.querySelector('settings-ui').shadowRoot.querySelector('settings-main').shadowRoot.querySelector('settings-basic-page').shadowRoot.querySelector('settings-section > settings-privacy-page').shadowRoot.querySelector('settings-clear-browsing-data-dialog').shadowRoot.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                if (checkbox.parentElement.innerText.includes("Passwords") || checkbox.parentElement.innerText.includes("Other sign-in data")) {
                    checkbox.checked = false;
                } else {
                    checkbox.checked = true;
                }
            });
        """)

        # Click the "Clear data" button
        driver.execute_script("""
            document.querySelector('settings-ui').shadowRoot.querySelector('settings-main').shadowRoot.querySelector('settings-basic-page').shadowRoot.querySelector('settings-section > settings-privacy-page').shadowRoot.querySelector('settings-clear-browsing-data-dialog').shadowRoot.querySelector('#clearBrowsingDataConfirm').click();
        """)
        time.sleep(5)  # Wait for the clearing process to complete

        print("Chrome browsing data cleared successfully without affecting passwords and sign-in data.")

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        # Close the browser
        driver.quit()

if __name__ == "__main__":
    # Path to your ChromeDriver executable
    chromedriver_path = "/path/to/chromedriver"  # Replace with the actual path to your ChromeDriver
    clear_chrome_browsing_data(chromedriver_path)
    