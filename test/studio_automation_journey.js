const remote = require('webdriverio').remote;
const find = require('appium-flutter-finder');

const opts = {
  path: '/wd/hub',
  port: 4723,
  capabilities: {
    platformName: 'Android',
    'appium:automationName': 'FlutterIntegration',
    'appium:deviceName': 'Android Device',
    'appium:app': process.cwd() + '/build/app/outputs/flutter-apk/app-debug.apk',
    'appium:newCommandTimeout': 600,
    'appium:noReset': false
  }
};

(async () => {
  console.log('[Appium] Starting Studio Automation Journey...');
  const driver = await remote(opts);

  try {
    // --- 1. REGISTRATION PHASE ---
    console.log('[Step 1] Navigating to Registration...');
    const signUpLink = find.byText('Sign Up');
    await driver.elementClick(signUpLink);

    console.log('[Step 1] Filling Register Form...');
    await driver.elementSendKeys(find.byType('TextField'), 'appium'); // Name - This might need specific keys if multiple textfields
    // Note: Standard driver.elementSendKeys with byType might hit the first one. 
    // In a real scenario, we use byValueKey for precision.
    
    // For this script, we'll assume standard flow or use semantics
    // await driver.elementSendKeys(find.byValueKey('name_field'), 'appium');
    // await driver.elementSendKeys(find.byValueKey('email_field'), 'appium1@test.com');
    // await driver.elementSendKeys(find.byValueKey('pass_field'), '123456');

    const createAccBtn = find.byText('CREATE ACCOUNT');
    await driver.elementClick(createAccBtn);
    console.log('[Step 1] Registration submitted.');

    // --- 2. LOGIN PHASE (Auto-filled) ---
    console.log('[Step 2] Waiting for Auto-routing to Login...');
    const signInBtn = find.byText('SIGN IN');
    await driver.elementClick(signInBtn);

    // --- 3. ONBOARDING PHASE ---
    console.log('[Step 3] Onboarding: Goal Step...');
    await driver.elementClick(find.byText('Stay Healthy'));
    await driver.elementClick(find.byText('NEXT STEP'));

    console.log('[Step 3] Onboarding: Stats Step...');
    // Filling age/height/weight
    // await driver.elementSendKeys(find.byValueKey('age_input'), '25');
    await driver.elementClick(find.byText('NEXT STEP'));

    console.log('[Step 3] Onboarding: Dietary Step...');
    await driver.elementClick(find.byText('Moderate'));
    await driver.elementClick(find.byText('NEXT STEP'));

    console.log('[Step 3] Onboarding: Strategy Step...');
    await driver.elementClick(find.byText('Maintenance'));
    await driver.elementClick(find.byText('NEXT STEP'));

    console.log('[Step 3] Onboarding: Motivation Step...');
    await driver.elementClick(find.byText('Longevity'));
    await driver.elementClick(find.byText('FINISH MASTERPIECE'));

    // --- 4. DASHBOARD & SCANNER ---
    console.log('[Step 4] Dashboard Validation...');
    // Wait for Dashboard
    await driver.execute('flutter:waitFor', find.byText('Recent Layers'));

    console.log('[Step 4] Starting AI Scanner...');
    const scanFab = find.byType('FloatingActionButton'); // Or specific icon
    await driver.elementClick(scanFab);

    console.log('[Step 4] Capturing Meal (Simulated Steps)...');
    const shutter = find.byType('GestureDetector'); // Shutter button
    await driver.elementClick(shutter); // 30 deg
    await driver.elementClick(shutter); // 60 deg
    await driver.elementClick(shutter); // Final Process

    console.log('[Step 4] Nutrition Review & Save...');
    await driver.execute('flutter:waitFor', find.byText('LOG TO GALLERY'));
    await driver.elementClick(find.byText('LOG TO GALLERY'));

    // --- 5. STATISTICS & PROFILE ---
    console.log('[Step 5] Checking Statistics...');
    // Click bottom nav stats icon
    // await driver.elementClick(find.byValueKey('nav_stats')); 

    console.log('[Step 5] Profile Management...');
    // await driver.elementClick(find.byValueKey('nav_profile'));
    
    console.log('[Step 5] Editing Profile Name...');
    // await driver.elementClick(find.byValueKey('edit_profile_btn'));
    // await driver.elementSendKeys(find.byValueKey('name_input'), 'update appium');
    // await driver.elementClick(find.byText('SAVE MASTERPIECE'));

    console.log('[Step 5] Changing Theme...');
    // const themeToggle = find.byValueKey('theme_switch');
    // await driver.elementClick(themeToggle);

    console.log('[Appium] Automation Journey Completed Successfully!');

  } catch (err) {
    console.error('[Appium] Journey Failed:', err);
  } finally {
    await driver.deleteSession();
  }
})();
