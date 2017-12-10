const Bounty0xTokenVesting = artifacts.require('Bounty0xTokenVesting');

contract('Bounty0xTokenVesting', ([ account0, account1, account2 ]) => {
  let VESTING_START_DATE;
  it('calls TokenVesting constructor properly', async () => {
    const tv = await Bounty0xTokenVesting.new(account1, 12);
    const VESTING_START_DATE = await tv.VESTING_START_DATE();

    const beneficiary = await tv.beneficiary();
    const cliff = await tv.cliff();
    const start = await tv.start();
    const duration = await tv.duration();
    const revocable = await tv.revocable();

    assert.strictEqual(beneficiary, account1);
    assert.strictEqual(cliff.valueOf(), VESTING_START_DATE.valueOf());
    assert.strictEqual(start.valueOf(), VESTING_START_DATE.valueOf());
    assert.strictEqual(duration.valueOf(), '' + (12 * 7 * 86400));
    assert.strictEqual(revocable, false);
  });
});