const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');

contract('Bounty0xCrowdsale', function (accounts) {
  let bounty0xcrowdsale;

  before('get deployed bounty0x crowdsale contract', async () => {
    bounty0xcrowdsale = await Bounty0xCrowdsale.deployed();
  });

  it('should be deployed', () => {
    assert.strictEqual(typeof bounty0xcrowdsale.address, 'string');
  });
});
