const remote = require('webdriverio').remote;
const find = require('appium-flutter-finder');
const fs = require('fs');
const path = require('path');

// OPTIMIZED FOR APPIUM 2.x (Standard 2025)
const opts = {
  hostname: '127.0.0.1',
  port: 4723,
  path: '/', // Appium 2.x uses / by default instead of /wd/hub
  capabilities: {
    platformName: 'Android',
    'appium:automationName': 'FlutterIntegration',
    'appium:deviceName': '10DE9M057K00057',
    'appium:app': path.join(process.cwd(), 'build/app/outputs/flutter-apk/app-debug.apk'),
    'appium:newCommandTimeout': 600,
    'appium:noReset': true
  }
};

async function takeScreenshot(driver, name) {
  try {
    const screenshot = await driver.takeScreenshot();
    const filePath = path.join(process.cwd(), '.github/screenshots', `${name}.png`);
    fs.writeFileSync(filePath, screenshot, 'base64');
    console.log(`[Appium] Screenshot saved: ${name}.png`);
  } catch (e) {
    console.error(`[Appium] Failed to take screenshot ${name}: ${e.message}`);
  }
}

(async () => {
  console.log('[Appium] Starting README Screenshot Automation Journey...');
  let driver;
  try {
    driver = await remote(opts);
    console.log('[Appium] Session established.');

    // 1. WAIT FOR DASHBOARD (Assuming already logged in from previous steps)
    console.log('[Step 1] Waiting for Dashboard to load...');
    await driver.execute('flutter:waitFor', find.byText('Recent Layers'));
    
    // --- DARK MODE SCREENSHOTS ---
    console.log('[Step 2] Capturing Dark Mode Screens...');
    await takeScreenshot(driver, 'dashboard_dark');
    
    // Go to Stats
    await driver.elementClick(find.byText('Stats'));
    await driver.execute('flutter:waitFor', find.byText('Weekly Kcal Trend'));
    await takeScreenshot(driver, 'stats_dark');
    
    // Go to Profile
    await driver.elementClick(find.byText('Profile'));
    await driver.execute('flutter:waitFor', find.byText('STUDIO SETTINGS'));
    await takeScreenshot(driver, 'profile_dark');

    // --- TOGGLE TO LIGHT MODE ---
    console.log('[Step 3] Switching to Light Mode...');
    const themeToggle = find.byText('Studio Theme');
    await driver.elementClick(themeToggle);
    await driver.pause(2000); // Wait for transition
    
    // --- LIGHT MODE SCREENSHOTS ---
    console.log('[Step 4] Capturing Light Mode Screens...');
    await takeScreenshot(driver, 'profile_light');
    
    // Go to Stats
    await driver.elementClick(find.byText('Stats'));
    await driver.pause(1000);
    await takeScreenshot(driver, 'stats_light');
    
    // Go to Home
    await driver.elementClick(find.byText('Home'));
    await driver.pause(1000);
    await takeScreenshot(driver, 'dashboard_light');

    // --- SCANNER SCREENSHOT ---
    console.log('[Step 5] Capturing AI Scanner UI...');
    const scanFab = find.byType('FloatingActionButton');
    await driver.elementClick(scanFab);
    await driver.pause(3000); // Wait for camera to warm up
    await takeScreenshot(driver, 'scanner_light');
    
    console.log('[Appium] All screenshots captured successfully!');

  } catch (err) {
    console.error('[Appium] Screenshot Automation Failed:', err);
  } finally {
    if (driver) await driver.deleteSession();
  }
})();
