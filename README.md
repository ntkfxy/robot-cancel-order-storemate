# StoreMate UC-22 — Robot Framework SeleniumLibrary

Aligned to **SPRS-Test-Cases.docx**, **TC-22001–TC-22009 (9 cases)**. The original GitHub repository uses Playwright and only includes TC-22001–TC-22008; this package is a separate Robot Framework Tutorial-style adaptation.

## Structure

- `tests-feature1/uc22-order-cancellation.robot`: test cases
- `resources/variables.robot`: test data and environment variables
- `resources/kws.robot`: reusable SeleniumLibrary keywords

## Setup

```bat
python -m pip install -r requirements.txt
set STOREMATE_BASE_URL=http://localhost:5173
set STOREMATE_EMAIL=your-test-email
set STOREMATE_PASSWORD=your-test-password
set STOREMATE_ORDER_22009=ORD-REPLACE-WITH-VALID-ORDER
robot --outputdir results tests-feature1/uc22-order-cancellation.robot
```

Use fresh eligible orders for destructive tests (22001, 22002, 22003, 22007); cancellation cannot be replayed on the same order. All IDs are from the existing repository, except TC-22009, which was absent. Verify the test orders exist and belong to the account.

## Known discrepancies / verification needed

1. **TC-22002**: document expected success but recorded actual error; test intentionally asserts expected success (may fail until app/backend is fixed).
2. **TC-22003**: existing Playwright test title says COD but navigates PENDING then expects PROCESSING; adapted to PENDING and marked for data verification.
3. **TC-22008**: source TC specifies SHIPPING; existing Playwright test used RECEIVED. Set a real SHIPPING order ID before running.
4. **TC-22007**: the source requires verifying saved _additional description_. Test checks success/status/reason, but description persistence assertion remains TODO pending confirmed order-detail selector; do not claim full coverage.
5. **TC-22009**: new case from document; supply a valid cancellable order ID.
6. **TC-22005**: original order status may differ from PENDING; verify its previous tab.
7. Verify current `data-test` selectors, page routes, and status labels with live StoreMate frontend. No tests have been executed against the live site.
8. SeleniumLibrary runs Chrome locally; Chrome must be installed.

## Mapping

TC-22001 / 22.1; TC-22002 / 22.2; TC-22003 / 22.1 success notification; TC-22004 / 22.1 stored reason; TC-22005 / 22.1 cancelled tab; TC-22006 / 22.3; TC-22007 / 22.4; TC-22008 / 22.5; TC-22009 / 22.6.
