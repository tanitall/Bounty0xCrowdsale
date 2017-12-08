const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');

contract('Bounty0xCrowdsale', function ([ deployer, presaleContributor1, presaleContributor2, contributor1, contributor2 ]) {
  let crowdsale;

  before('get deployed bounty0x crowdsale contract', async () => {
    crowdsale = await Bounty0xCrowdsale.deployed();
  });

  it('should be deployed', () => {
    assert.strictEqual(typeof crowdsale.address, 'string');
  });

  it('allows the owner to withdraw ether at any time');
  it('does not accept contributions while paused');
  it('does not accept 0 value contributions');
  it('should not accept contributions until SALE_START_DATE');
  it('should not accept contributions after SALE_END_DATE');
  it('should not accept contributions past beyond hard cap');
  it('only accepts contributions from whitelisted addresses in first 24 hours');
  it('only accepts $1.5k USD per address during whitelist period');
  it('accepts contributions from any address after the whitelist period for 24 hours');
  it('limits gas price sent with contributions for 24 hours after whitelist period');
  it('limits gas sent with contributions for 24 hours after whitelist period');
  it('limits total contributions to $10k USD for 24 hours after whitelist period');
  it('adds to total contributions for each wei sent');
  it('records contributions by address correctly');
  it('rewards the correct amount of BNTY for contributions');
  it('logs all contributions');
});
