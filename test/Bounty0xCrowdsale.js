const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');

contract('Bounty0xCrowdsale', function (accounts) {
  let crowdsale;

  before('get deployed bounty0x crowdsale contract', async () => {
    crowdsale = await Bounty0xCrowdsale.deployed();
  });

  it('should be deployed', () => {
    assert.strictEqual(typeof crowdsale.address, 'string');
  });
});
